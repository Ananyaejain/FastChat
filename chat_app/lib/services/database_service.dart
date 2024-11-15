import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:chat_app/utils.dart';

class DatabaseService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final GetIt getIt = GetIt.instance;
  late AuthService _authService;

  CollectionReference? _chatCollections;
  CollectionReference? _usersCollections;

  DatabaseService() {
    _setupCollectionReference();
    _authService = getIt.get<AuthService>();
  }

  void _setupCollectionReference() {
    _usersCollections =
        _firebaseFirestore.collection('users').withConverter<UserProfile>(
              fromFirestore: (snapshots, _) =>
                  UserProfile.fromJson(snapshots.data()!),
              toFirestore: (userProfile, _) => userProfile.toJson(),
            );
    _chatCollections =
        _firebaseFirestore.collection('chats').withConverter<Chat>(
              fromFirestore: (snapshots, _) =>
                  Chat.fromJson(json: snapshots.data()!),
              toFirestore: (chats, _) => chats.toJson(),
            );
  }

  Future<void> createUserProfile({required UserProfile userProfile}) async {
    await _usersCollections?.doc(userProfile.uid).set(userProfile);
  }

  Stream<QuerySnapshot<UserProfile>> getUserProfiles() {
    return _usersCollections
        ?.where('uid', isNotEqualTo: _authService.user!.uid)
        .snapshots() as Stream<QuerySnapshot<UserProfile>>;
  }

  Stream<DocumentSnapshot<Chat>> getChatData(String uid1, String uid2) {
    String chatID = generateChatID(
      uid1: uid1,
      uid2: uid2,
    );
    return _chatCollections!.doc(chatID).snapshots()
        as Stream<DocumentSnapshot<Chat>>;
  }

  Future<bool> doesChatExist(String uid1, String uid2) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final result = await _chatCollections?.doc(chatID).get();
    if (result != null) {
      return result.exists;
    }
    return false;
  }

  Future<void> createNewChat(String uid1, String uid2) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatCollections!.doc(chatID);
    final chat = Chat(
      id: chatID,
      messages: [],
      participants: [uid1, uid2],
    );
    await docRef.set(chat);
  }

  Future<void> sendChatMessage(
      String uid1, String uid2, Message message) async {
    String chatID = generateChatID(
      uid1: uid1,
      uid2: uid2,
    );
    final docRef = _chatCollections!.doc(chatID);
    await docRef.update(
      {
        'messages': FieldValue.arrayUnion(
          [
            message.toJson(),
          ],
        ),
      },
    );
  }

  Future<void> updatePushToken(String pushToken) async{
    final userID = _authService.user!.uid;
    final docRef = _usersCollections!.doc(userID);
    await docRef.update({
      'pushToken': pushToken,
    });
  }
}