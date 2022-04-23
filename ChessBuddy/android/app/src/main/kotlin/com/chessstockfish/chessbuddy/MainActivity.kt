package com.dracogroupinc.chessmaze

import io.flutter.embedding.android.FlutterActivity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine

import android.os.Bundle
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.lang.System.loadLibrary
import android.util.Log

import java.lang.annotation.Native

import android.R

import android.widget.TextView


class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState);

        try {
            System.loadLibrary("api");
        } catch (e:Exception) {
            try {
                System.loadLibrary("api");
            } catch (e2:Exception) {
            }
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "android_app_retain").apply {
            setMethodCallHandler { method, result ->
                if (method.method == "sendToBackground") {
                    moveTaskToBack(true)
                }
            }
        };

        Runtime.getRuntime().gc();
    }

    /*
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPluginBinding) {
        //val channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "tflite_flutter_plugin")
        //channel.setMethodCallHandler(TfliteFlutterPlugin())
        //java.lang.System.loadLibrary()
        System.loadLibrary("libapi");


    }

     */
}
