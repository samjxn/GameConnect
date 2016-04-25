part of game_connect_client.src.models;

class Player {

  String _clientId;
  String _displayName;

  String get clientId => _clientId;
  String get displayName => _displayName;

  Player(this._clientId, this._displayName);
}