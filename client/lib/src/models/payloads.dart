part of game_connect_client.src.models;

class RegisterClientPayload {

  String _clientId;
  String _displayName;

  String get clientId => _clientId;
  String get displayName => _displayName;

  RegisterClientPayload(this._clientId, this._displayName);
}

