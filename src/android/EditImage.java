package org.apache.cordova.camera;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.FileUtils;
import android.provider.MediaStore;
import android.util.Base64;

import com.outsystems.imageeditor.view.ImageEditorActivity;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

public class EditImage extends CordovaPlugin {


    private static int EDIT_RESULT = 0;

    private String resultImagePath = "";
    public CallbackContext callbackContext;


    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;

        if(action.equals("edit")) {

            String imageBase64 = args.getString(0);
            byte[] imageByteArray = Base64.decode(imageBase64, Base64.NO_WRAP);
            Bitmap imageBitmap = BitmapFactory.decodeByteArray(imageByteArray, 0, imageByteArray.length);

            editImage(imageBitmap);
            return true;

        }

        return false;
    }

    private void editImage(Bitmap bitmap){

        //Creates temp file
        String inputFilePath = createCaptureFile(System.currentTimeMillis() + "").getAbsolutePath();
        Uri inputFileUri = Uri.parse(inputFilePath);
        File inputFile = new File(inputFilePath);

        try {

            //Writes bitmap in temp file
            OutputStream outStream = new FileOutputStream(inputFile);
            bitmap.compress(Bitmap.CompressFormat.JPEG, 100, outStream);
            outStream.flush();
            outStream.close();

            openCropActivity(inputFileUri);

            /*
            Bitmap result = getScaledAndRotatedBitmap(inputFilePath);

            ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
            if(result.compress(CompressFormat.JPEG, 100, byteArrayOutputStream)){
                byte[] byteArray = byteArrayOutputStream.toByteArray();
                String base64Result = Base64.encodeToString(byteArray, Base64.NO_WRAP);
                this.callbackContext.success(base64Result);
            }
             */

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);

        if(requestCode == EDIT_RESULT) {
            if (resultCode == Activity.RESULT_OK) {

                Bitmap result = BitmapFactory.decodeFile(resultImagePath);

                ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                if(result.compress(Bitmap.CompressFormat.JPEG, 100, byteArrayOutputStream)){
                    byte[] byteArray = byteArrayOutputStream.toByteArray();
                    String base64Result = Base64.encodeToString(byteArray, Base64.NO_WRAP);
                    this.callbackContext.success(base64Result);
                }


            }
            else if (resultCode == Activity.RESULT_CANCELED) {
                this.callbackContext.error("No Image Selected");
            }
            else {
                this.callbackContext.error("Did not complete!");
            }

        }

    }

    private File createCaptureFile(String fileName) {
        if (fileName.isEmpty()) {
            fileName = ".Pic";
        }
        fileName = fileName + ".jpeg";
        return new File(getTempDirectoryPath(), fileName);
    }
    private String getTempDirectoryPath() {
        File cache = cordova.getActivity().getCacheDir();
        cache.mkdirs();
        return cache.getAbsolutePath();
    }

    private void openCropActivity(Uri picUri) {

        Intent cropIntent = new Intent(this.cordova.getActivity(), ImageEditorActivity.class);

        // creates output file
        resultImagePath = createCaptureFile(System.currentTimeMillis() + "").getAbsolutePath();

        cropIntent.putExtra(ImageEditorActivity.IMAGE_OUTPUT_URI_EXTRAS, resultImagePath);
        cropIntent.putExtra(ImageEditorActivity.IMAGE_INPUT_URI_EXTRAS, picUri.toString());

        if (this.cordova != null) {
            this.cordova.startActivityForResult(
                    this,
                    cropIntent,
                    EDIT_RESULT);
        }

    }

}