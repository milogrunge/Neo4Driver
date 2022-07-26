library neo4dart.neo_client;

import 'package:http/http.dart' show Client;
import 'package:neo4dart/src/entity/path.dart';
import 'package:neo4dart/src/exception/invalid_id_exception.dart';
import 'package:neo4dart/src/exception/no_param_node_exception.dart';
import 'package:neo4dart/src/exception/no_properties_exception.dart';
import 'package:neo4dart/src/model/node.dart';
import 'package:neo4dart/src/model/property_to_check.dart';
import 'package:neo4dart/src/model/relationship.dart';
import 'package:neo4dart/src/service/neo_service.dart';

class NeoClient {
  late NeoService _neoService;

  static final NeoClient _instance = NeoClient._internal();

  NeoClient._internal();

  /// Constructs NeoClient.
  /// Database's address can be added, otherwise the localhost address is used with Neo4J's default port is used (7474).
  factory NeoClient() => _instance;

  factory NeoClient.withoutCredentialsForTest({String databaseAddress = 'http://localhost:7474/'}) {
    _instance._neoService = NeoService(databaseAddress);
    return _instance;
  }

  /// Constructs NeoClient with authentication credentials (user & password).
  /// Database's address can be added, otherwise the localhost address is used with Neo4J's default port is used (7474).
  /// Username and password are encoded to build the authentication token.
  ///
  /// If Token-authentication is not working, credentials can be added directly in the database's address following format
  /// http://username:password@localhost:7474
  factory NeoClient.withAuthorization({
    required String username,
    required String password,
    String databaseAddress = 'http://localhost:7474/',
  }) {
    _instance._neoService = NeoService.withAuthorization(
      username: username,
      password: password,
      databaseAddress: databaseAddress,
    );
    return _instance;
  }

  factory NeoClient.withHttpClient({required Client httpClient}) {
    _instance._neoService = NeoService.withHttpClient(httpClient);
    return _instance;
  }

  //#region CREATE METHODS
  /// Finds relationship with given ID (if id<0, return null).
  Future<Relationship?> findRelationshipById(int id) async {
    if (id >= 0) {
      return _neoService.findRelationshipById(id);
    } else {
      return null;
    }
  }

  Future<Relationship?> findRelationshipWithStartNodeIdEndNodeId(int startNode, int endNode) async {
    if (startNode >= 0 && endNode >= 0) {
      return _neoService.findRelationshipWithStartNodeIdEndNodeId(startNode, endNode);
    } else {
      throw InvalidIdException(cause: "ID can't be < 0");
    }
  }

  //A TESTER 20 JUILLET
  Future<List<Relationship?>> findRelationshipWithNodeProperties(String label, Map<String, dynamic> parameters) async {
    if (parameters.isNotEmpty) {
      return _neoService.findRelationshipWithNodeProperties(parameters, label);
    } else {
      throw NoParamNodeException(cause: "To find nodes parameters are needed");
    }
  }

  Future<bool> isRelationshipExistsBetweenTwoNodes(int firstNode, int secondNode) {
    if (firstNode >= 0 && secondNode >= 0) {
      return _neoService.isRelationshipExistsBetweenTwoNodes(firstNode, secondNode);
    } else {
      throw InvalidIdException(cause: "ID can't be negative");
    }
  }

  Future<Node> updateNodeWithId({required int nodeId, required Map<String, dynamic> propertiesToAddOrUpdate}) {
    if (propertiesToAddOrUpdate.isNotEmpty) {
      return _neoService.updateNodeWithId(nodeId, propertiesToAddOrUpdate);
    } else {
      throw NoPropertiesException(cause: "Properties map is empty");
    }
  }

  Future<Relationship> updateRelationshipWithId(
      {required int relationshipId, required Map<String, dynamic> propertiesToAddOrUpdate}) {
    if (propertiesToAddOrUpdate.isNotEmpty) {
      return _neoService.updateRelationshipWithId(relationshipId, propertiesToAddOrUpdate);
    } else {
      throw NoPropertiesException(cause: "Properties map is empty");
    }
  }

  /// Find all nodes with given properties
  /// Relationship not returned
  Future<List<Node>> findAllNodesByProperties({required List<PropertyToCheck> propertiesToCheck}) {
    if (propertiesToCheck.isNotEmpty) {
      return _neoService.findAllNodesByProperties(propertiesToCheck);
    } else {
      throw NoPropertiesException(cause: "Can't search nodes by properties with empty properties list");
    }
  }

  /// Finds all nodes in database.
  /// Relationship are not return.
  Future<List<Node>> findAllNodes() async {
    return _neoService.findAllNodes();
  }

  Future<Node?> findNodeById(int id) async {
    return _neoService.findNodeById(id);
  }

  /// Finds all nodes in database with given type
  Future<List<Node>?> findAllNodesByLabel(String label) async {
    if (label != "" && label.isNotEmpty) {
      return _neoService.findAllNodesByLabel(label.replaceAll(' ', ''));
    } else {
      return null;
    }
  }
  //#endregion

  Future<Path> computeShortestPathDijkstra({
    required double sourceLat,
    required double sourceLong,
    required double targetLat,
    required double targetLong,
    required String projectionName,
    required String propertyWeight,
  }) {
    return _neoService.computeShortestPathDijkstra(
        sourceLat, sourceLong, targetLat, targetLong, projectionName, propertyWeight);
  }

  Future<num> computeDistanceBetweenTwoPoints(
      {required double latP1, required double longP1, required double latP2, required double longP2}) {
    return _neoService.computeDistanceBetweenTwoPoints(latP1, longP1, latP2, longP2);
  }

  //#region PROJECTION
  Future<bool> createGraphProjection({
    required String projectionName,
    required String label,
    required String relationshipName,
    required String relationshipProperty,
    required bool isDirected,
  }) {
    return _neoService.createGraphProjection(projectionName, label, relationshipName, relationshipProperty, isDirected);
  }
  //#endregion

  //#region CREATE METHODS
  Future<Relationship> createRelationship({
    required int startNodeId,
    required int endNodeId,
    required String relationName,
    required Map<String, dynamic> properties,
  }) {
    return _neoService.createRelationship(startNodeId, endNodeId, relationName, properties);
  }

  Future<List<Relationship>> createRelationshipFromNodeToNodes({
    required int startNodeId,
    required List<int> endNodesId,
    required String relationName,
    required Map<String, dynamic> properties,
  }) {
    return _neoService.createRelationshipFromNodeToNodes(startNodeId, endNodesId, relationName, properties);
  }

  Future<void> createNodeWithNode(Node node) {
    return _neoService.createNodeWithNodeParam(node);
  }

  Future<Node?> createNode({required List<String> labels, required Map<String, dynamic> properties}) async {
    return _neoService.createNode(labels: labels, properties: properties);
  }
  //#endregion

  //#region DELETE METHODS
  Future<void> deleteNodeById(int id) {
    return _neoService.deleteNodeById(id);
  }

  Future<void> deleteAllNode() {
    return _neoService.deleteAllNode();
  }
  //#endregion
}
