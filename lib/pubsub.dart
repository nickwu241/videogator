import 'package:googleapis_auth/auth_io.dart';
import 'package:gcloud/pubsub.dart';

Future<PubSub> getPubSub() async {
  final credentials = ServiceAccountCredentials.fromJson(r"""
""");
  // Get an HTTP authenticated client using the service account credentials.
  var scopes = PubSub.SCOPES;
  var client = await clientViaServiceAccount(credentials, scopes);
  var pubsub = PubSub(client, 'videogator');
  return pubsub;
}

