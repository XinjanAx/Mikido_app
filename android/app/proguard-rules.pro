# flutter_local_notifications persiste los detalles de la notificación
# programada con Gson y los recupera por reflexión al disparar la alarma.
# R8 borra la información de tipo genérico que Gson necesita, causando
# "RuntimeException: Missing type parameter" al abrir
# ScheduledNotificationReceiver y matando el proceso.
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep public class * implements java.lang.reflect.Type
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-dontwarn com.dexterous.flutterlocalnotifications.**

# Reglas oficiales de Gson para R8 3.0+: un simple "-keep class * extends
# TypeToken" no alcanza, R8 sigue pudiendo borrar la firma genérica de la
# subclase anónima que arma ScheduledNotificationReceiver. Estas dos líneas
# son las que Gson documenta específicamente para ese caso.
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
