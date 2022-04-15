import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:secretic/enums/message_type.dart';
import 'package:secretic/models/local_mesage_model.dart';
import 'package:secretic/models/network_message_model.dart';
import 'package:secretic/options.dart';

import 'package:secretic/services/authentication_service.dart';

class CryptoService {
  static final CryptoService _instance = CryptoService._internal();
  late SimpleKeyPair keyPair;
  late SimplePublicKey publicKey;

  final algorithm = X25519();
  final storage = FlutterSecureStorage();
  final kdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
  final encryption = AesCtr.with256bits(
    macAlgorithm: Hmac.sha256(),
  );

  factory CryptoService() {
    return _instance;
  }

  _init() async {
    if (await storage.containsKey(key: localStorageKey)) {
      _readKeys();
    } else {
      _generateKeyPairs();
    }
  }

  CryptoService._internal() {
    _init();
  }
  _generateKeyPairs() async {
    var newPair = await algorithm.newKeyPair();

    var seed = await newPair.extractPrivateKeyBytes();
    await _storeSeed(seed);
    keyPair = await algorithm.newKeyPairFromSeed(seed);
    publicKey = await keyPair.extractPublicKey();
  }

  _storeSeed(List<int> data) async {
    storage.write(
      key: localStorageKey,
      value: base64.encode(data),
    );
  }

  _readKeys() async {
    if (await storage.containsKey(key: localStorageKey)) {
      String seedString = (await storage.read(key: localStorageKey))!;
      List<int> seed = base64.decode(seedString);
      keyPair = await algorithm.newKeyPairFromSeed(seed);
      var pubKey = await keyPair.extractPublicKey();
      publicKey = pubKey;
    } else {
      _generateKeyPairs();
    }
  }

  Future<SecretKey> sharedSecretKey(SimplePublicKey pubKey) async {
    SecretKey key = await algorithm.sharedSecretKey(
      keyPair: keyPair,
      remotePublicKey: pubKey,
    );

    final nonce = [
      55,
      77,
      33,
      102,
      114,
      2,
      52,
      98,
      12,
      8,
      41,
      93,
      62,
      16,
      72,
      31
    ];
    SecretKey encryptionKey = await kdf.deriveKey(secretKey: key, nonce: nonce);

    return encryptionKey;
  }

  Future<LocalMessage> decryptNetworkMessage(
      NetworkMessage networkMessage) async {
    String uid = GetIt.I<AuthenticationService>().user!.uid;
    var sharedkey = await sharedSecretKey(SimplePublicKey(
      base64.decode(networkMessage.senderPubKeyString),
      type: KeyPairType.x25519,
    ));
    SecretBox secretBox = SecretBox.fromConcatenation(
        base64Decode(networkMessage.encryptedMessage),
        nonceLength: 16,
        macLength: 32);

    var bytesList = await encryption.decrypt(secretBox, secretKey: sharedkey);

    LocalMessage message = LocalMessage(
      conversationID: networkMessage.conversationID,
      timestamp: networkMessage.timestamp,
      senderUID: networkMessage.senderUID,
      recieverUID: networkMessage.recieverUID,
      messageContent: utf8.decode(bytesList),
      messageType: (uid == networkMessage.senderUID)
          ? MessageType.sent
          : MessageType.received,
    );

    return message;
  }

  Future<NetworkMessage> encryptLocalMessage(
      LocalMessage message, SecretKey secretKey) async {
    CryptoService cryptoService = CryptoService();

    var cipherText = await cryptoService.encryption.encrypt(
      utf8.encode(message.messageContent),
      secretKey: secretKey,
    );

    return NetworkMessage(
      senderPubKeyString: base64.encode(cryptoService.publicKey.bytes),
      conversationID: message.conversationID,
      timestamp: message.timestamp,
      senderUID: message.senderUID,
      recieverUID: message.recieverUID,
      encryptedMessage: base64.encode(cipherText.concatenation()),
    );
  }
}
