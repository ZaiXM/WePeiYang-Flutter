package com.twt.service

import android.app.AlertDialog
import android.app.PendingIntent
import android.content.ContentValues
import android.content.Intent
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.example.umeng_sdk.UmengSdkPlugin
import com.google.gson.Gson
import com.tencent.tauth.Tencent
import com.twt.service.widget.ScheduleWidgetProvider
import com.umeng.analytics.MobclickAgent
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.*
import java.io.File
import java.lang.ref.WeakReference
import java.util.*

class MainActivity : FlutterFragmentActivity() {
    companion object {
        const val APP_ID = "1104743406"
        const val APP_AUTHORITIES = "com.twt.service.FileProvider"
    }

    var messageChannel: MethodChannel? = null
    lateinit var placeChannel: MethodChannel
    var shareChannel: MethodChannel? = null
    val mTencent by lazy { Tencent.createInstance(APP_ID, this@MainActivity, APP_AUTHORITIES) }
    private var imgSaveChannel: BasicMessageChannel<String>? = null
    private val locationClient by lazy { AMapFactory.init(placeChannel, applicationContext) }
    private val notificationManager: NotificationManagerCompat by lazy {
        NotificationManagerCompat.from(this)
    }

    override fun onPause() {
        super.onPause()
        MobclickAgent.onPause(this)
        Log.i("UMLog", "onPause@MainActivity")
    }

    override fun onResume() {
        super.onResume()
        MobclickAgent.onResume(this)
        Log.i("UMLog", "onResume@MainActivity")
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WBYApplication.activity = WeakReference(this)
        UmengSdkPlugin.setContext(this)
        updateWidget()
        handleIntent()
    }

    override fun onNewIntent(intent: Intent) {
        setIntent(intent)
        handleIntent()
        super.onNewIntent(intent)
    }

    private fun updateWidget() {
        val intent = Intent(this@MainActivity, ScheduleWidgetProvider::class.java).apply {
            action = "com.twt.appwidget.refresh"
        }
        sendBroadcast(intent)
    }

    private fun handleIntent() {
        Log.d("WBYIntent", intent.dataString ?: "null")
        if (intent.data?.host?.equals("weipeiyang.app") == true) {
            intent.data?.let {
                Log.d(
                    "WBYINTENT",
                    (it.host ?: "null ") + "  " + (it.path ?: "null ") + "  " + (it.query
                        ?: "null ")
                )
                when (it.path) {
                    "/feedback" -> {
                        val postId = it.query?.split("=")?.get(1)?.toInt() ?: -1
                        WBYApplication.eventList.add(
                            Event(
                                IntentEvent.FeedbackPostPage.type,
                                postId
                            )
                        )
                    }
                    "/mailbox" -> {
                        val url = it.query?.split("=")?.get(1) ?: ""
                        WBYApplication.eventList.add(Event(IntentEvent.WBYPushHtml.type, url))
                    }
                    else -> {

                    }
                }
            }
        } else {
            intent.dataString?.let {
                Log.d("WBYIntent", it)
                try {
                    val intentContent = Gson().fromJson(it, IntentType::class.java)
                    when (intentContent.type) {
                        IntentEvent.FeedbackPostPage.type -> {
                            val postId = intentContent.data.toIntOrNull() ?: -1
                            WBYApplication.eventList.add(
                                Event(
                                    IntentEvent.FeedbackPostPage.type,
                                    postId
                                )
                            )
                        }
                        IntentEvent.WBYPushOnlyText.type -> {
                            WBYApplication.eventList.add(
                                Event(
                                    IntentEvent.WBYPushOnlyText.type,
                                    it
                                )
                            )
                        }
                        IntentEvent.WBYPushHtml.type -> {
                            val url =
                                Gson().fromJson(intentContent.data, WBYPushMessage::class.java).url
                            WBYApplication.eventList.add(
                                Event(IntentEvent.WBYPushHtml.type, url)
                            )
                        }
                        IntentEvent.SchedulePage.type -> {
                            WBYApplication.eventList.add(
                                Event(
                                    IntentEvent.SchedulePage.type,
                                    "go to schedule page without data"
                                )
                            )
                        }
                        else -> {
                        }
                    }
                } catch (e: Exception) {
                    Log.d("WBYIntent", "go from unknown location")
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        messageChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.twt.service/message"
        ).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {

                    // TODO: delete
                    "getPostId" -> {
                        result.success(WBYApplication.postId)
                        WBYApplication.postId = -1
                    }

                    "getCid" -> {
                        result.success(WBYApplication.tempCid)
                    }
                    "cancelNotification" -> {
                        try {
                            call.argument<Int>("id")
                        } catch (e: Exception) {
                            -1
                        }.takeIf { it != -1 }?.let {
                            notificationManager.cancel(it)
                        }
                        result.success("cancel success")
                    }

                    // TODO: delete
                    "getMessageUrl" -> {
                        result.success(WBYApplication.url)
                        WBYApplication.url = ""
                    }

                    "refreshScheduleWidget" -> {
                        updateWidget()
                    }
                    "getLastEvent" -> {
                        with(WBYApplication.eventList){
                            val event = last()
                            if (size > 1){
                                removeLast()
                            }
                            Log.d("WBYINTENT",size.toString())
                            if (event.type!=-1){
                                Log.d("WBYINTENT",event.toString())
                                result.success(
                                    mapOf(
                                        "event" to event.type,
                                        "data" to event.data
                                    )
                                )
                            }
                        }
                    }
                    else -> result.error("-1", "cannot find method", null)
                }
            }
        }
        placeChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.twt.service/place"
        ).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "getLocation" -> {
                        locationClient.startLocation()
                    }
                    else -> result.error("-1", "cannot find method", null)
                }
            }
        }
        imgSaveChannel = BasicMessageChannel<String>(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.twt.service/saveBase64Img",
            StringCodec.INSTANCE
        ).apply {
            setMessageHandler { message, reply ->
                message?.let {
                    try {
                        savePictureToAlbum(it)
                        reply.reply("success")
                    } catch (e: Exception) {
                        reply.reply(null)
                    }
                }
            }
        }
        shareChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.twt.service/share"
        ).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "shareToQQ" -> {
                        try {
                            QQFactory.share(call)
                            result.success("success")
                        } catch (e: Exception) {
                            result.error("-1", "cannot share to qq", null)
                        }
                    }
                    else -> result.error("-1", "cannot find method", null)
                }
            }
        }
        super.configureFlutterEngine(flutterEngine)
    }

    private fun savePictureToAlbum(filePath: String) {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {//Android Q把文件插入到系统图库
            val values = ContentValues()
            val file = File(filePath)
            values.put(MediaStore.Images.Media.DESCRIPTION, "This is an qr image")
            values.put(MediaStore.Images.Media.DISPLAY_NAME, file.name)
            values.put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
            values.put(MediaStore.Images.Media.TITLE, "Image.jpg")
            values.put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/微北洋")

            val external = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
            val resolver = this.contentResolver
            val uri = resolver.insert(external, values)
            uri?.let {
                file.inputStream().use { input ->
                    resolver.openOutputStream(it).use { output ->
                        output?.let {
                            input.copyTo(it)
                        }
                    }
                }
            }
        } else {
            MediaScannerConnection(this, null).apply {
                connect()
                if (isConnected) {
                    scanFile(filePath, "image/jpeg")
                }
            }
        }
    }

    fun showNotification(data: MessageData) {
        fun send(id: Int, title: String, content: String, intent: Intent) {
            val pendingIntent = PendingIntent.getActivity(this, 0, intent, 0)
            val builder = NotificationCompat.Builder(this, "1")
                .setSmallIcon(R.drawable.push_small)
                .setContentTitle(title)
                .setContentText(content)
                .setContentIntent(pendingIntent)
                .setWhen(System.currentTimeMillis())
                .setAutoCancel(true)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                Log.d("WBY", "Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP")
                val intent2 = Intent(this, MainActivity::class.java)
                val pIntent = PendingIntent.getActivity(
                    applicationContext,
                    1,
                    intent2,
                    PendingIntent.FLAG_UPDATE_CURRENT
                )
                builder.setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                builder.setFullScreenIntent(pIntent, false)
            }
            notificationManager.notify(id, builder.build())
        }

        // 点击时想要打开的界面
        val intent = Intent(this, MainActivity::class.java)

        when (data) {
            is FeedbackMessage -> {
                // 一般点击通知都是打开独立的界面，为了避免添加到现有的activity栈中，可以设置下面的启动方式
                // intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                val intentContent = IntentType(
                    type = IntentEvent.FeedbackPostPage.type,
                    data = data.question_id.toString()
                )
                intent.data = Uri.parse(Gson().toJson(intentContent))
                send(data.question_id, data.title, data.content, intent)
            }
            is WBYPushMessage -> {
                val intentContent =
                    IntentType(type = IntentEvent.WBYPushHtml.type, data = Gson().toJson(data))
                intent.data = Uri.parse(Gson().toJson(intentContent))
                send(0, data.title, data.content, intent)
            }
        }
    }

    fun alertDialog(data: String) {
        val builder = AlertDialog.Builder(this)
        builder.setPositiveButton("确定", null)
        builder.setTitle(data)
        builder.show()
    }

    /**
     * 定位监听
     */
}

data class IntentType(
    val type: Int,
    val data: String,
)

enum class IntentEvent(val type: Int) {
    FeedbackPostPage(1),
    WBYPushOnlyText(2),
    WBYPushHtml(3),
    SchedulePage(4),
}