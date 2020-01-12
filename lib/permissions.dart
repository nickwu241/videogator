import 'package:permission_handler/permission_handler.dart';

Future askForPermissions() async {
  Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler()
      .requestPermissions([PermissionGroup.microphone]);
}
