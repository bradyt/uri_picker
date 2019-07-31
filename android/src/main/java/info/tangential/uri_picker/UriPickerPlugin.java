package info.tangential.uri_picker;

import android.app.Activity;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.ParcelFileDescriptor;
import android.provider.OpenableColumns;
import androidx.annotation.NonNull;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

/**
 * UriPickerPlugin
 */
public class UriPickerPlugin implements MethodCallHandler, ActivityResultListener {

  private static final int OPEN_REQUEST_CODE = 0;
  private static final int WRITE_REQUEST_CODE = 1;

  private final Registrar registrar;
  private Result result;

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "tangential.info/uri_picker");
    UriPickerPlugin plugin = new UriPickerPlugin(registrar);
    channel.setMethodCallHandler(plugin);
    registrar.addActivityResultListener(plugin);
  }

  private UriPickerPlugin(Registrar registrar) {
    this.registrar = registrar;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    this.result = result;
    if (call.method.equals("performFileSearch")) {
      performFileSearch();
    } else if (call.method.equals("createFile")) {
      createFile();
    } else {
      Uri uri = Uri.parse((String) call.argument("uri"));
      switch (call.method) {
        case "getDisplayName":
          getDisplayName(uri);
          break;
        case "readTextFromUri":
          try {
            result.success(readTextFromUri(uri));
          } catch (IOException e) {
            e.printStackTrace();
          }
          break;
        case "appendToFile":
          appendToFile(uri, (String) call.argument("contentsToAppend"));
          break;
        default:
          result.notImplemented();
      }
    }
  }

  private void performFileSearch() {
    documentRequest(Intent.ACTION_OPEN_DOCUMENT, OPEN_REQUEST_CODE);
  }

  private void createFile() {
    documentRequest(Intent.ACTION_CREATE_DOCUMENT, WRITE_REQUEST_CODE);
  }

  private void documentRequest(String action, int requestCode) {
    Intent intent = new Intent(action);
    intent.addCategory(Intent.CATEGORY_OPENABLE);
    intent.setType("text/plain");
    intent.setFlags(
        Intent.FLAG_GRANT_READ_URI_PERMISSION
            | Intent.FLAG_GRANT_WRITE_URI_PERMISSION
            | Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION);
    registrar.activity().startActivityForResult(intent, requestCode);
  }

  @Override
  public boolean onActivityResult(int requestCode, int resultCode, Intent resultData) {
    if (resultCode == Activity.RESULT_OK) {
      if (requestCode == OPEN_REQUEST_CODE || requestCode == WRITE_REQUEST_CODE) {
        Uri uri = resultData.getData();
        if (uri != null) {
          takePersistablePermission(uri);
          result.success(uri.toString());
          return true;
        }
      }
    }
    result.error("onActivityResult",
        "Unhandled request code, or null result data", null);
    return true;
  }

  private void getDisplayName(Uri uri) {
    String displayName = null;
    try (Cursor cursor = registrar.activity().getContentResolver()
        .query(uri, null, null, null, null, null)) {
      if (cursor != null && cursor.moveToFirst()) {
        displayName = cursor.getString(
            cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME));
      }
    }
    result.success(displayName);
  }

  private void takePersistablePermission(Uri uri) {
    try {
      registrar.activeContext().getContentResolver()
          .takePersistableUriPermission(uri,
              Intent.FLAG_GRANT_READ_URI_PERMISSION
                  | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  private void appendToFile(Uri uri, String contentsToAppend) {
    try {
      alterDocument(uri, readTextFromUri(uri) + contentsToAppend);
    } catch (IOException e) {
      e.printStackTrace();
      result.error("", "Could not read before writing to " + uri.toString(), null);
    }
  }

  private String readTextFromUri(Uri uri) throws IOException {
    InputStream inputStream = registrar.activeContext().getContentResolver()
        .openInputStream(uri);
    BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
    StringBuilder stringBuilder = new StringBuilder();
    String line;
    while ((line = reader.readLine()) != null) {
      stringBuilder.append(line);
      stringBuilder.append("\n");
    }
    if (inputStream != null) {
      inputStream.close();
    }
    return stringBuilder.toString();
  }

  private void alterDocument(Uri uri, String newContents) {
    try {
      ParcelFileDescriptor pfd = registrar.activeContext().getContentResolver()
          .openFileDescriptor(uri, "w");
      if (pfd != null) {
        FileOutputStream fileOutputStream = new FileOutputStream(pfd.getFileDescriptor());
        fileOutputStream.write(newContents.getBytes());
        fileOutputStream.close();
        pfd.close();
        result.success(null);
      } else {
        result.error("", "openFileDescriptor returned null, for " + uri.toString(), null);
      }
    } catch (FileNotFoundException e) {
      String name = e.getClass().getName();
      String message = e.getMessage();
      result.error(name, message, null);
    } catch (IOException e) {
      String name = e.getClass().getName();
      String message = e.getMessage();
      result.error(name, message, null);
    }
  }
}
