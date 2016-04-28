part of game_connect_client.src.models;

class RegisterClientPayload {

  String _clientId;
  String _displayName;

  String get clientId => _clientId;
  String get displayName => _displayName;

  RegisterClientPayload(this._clientId, this._displayName);
}

class ChatPayload {
  String _clientId;
  String _message;

  String get clientId => _clientId;
  String get message => _message;

  ChatPayload(this._clientId, this._message);
}

