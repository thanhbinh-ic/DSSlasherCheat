#import <Foundation/Foundation.h>
#include <dlfcn.h>
#include <pthread.h>
#include <unistd.h>

// Định nghĩa cấu trúc chuẩn của IL2CPP MethodInfo
struct MethodInfo {
    void* methodPointer;
    // Các trường khác của Unity có thể bỏ qua vì ta chỉ cần trường đầu tiên
};

typedef void* (*il2cpp_get_class_t)(const char* namespaze, const char* name);
typedef struct MethodInfo* (*il2cpp_class_get_method_from_name_t)(void* klass, const char* name, int argsCount);
typedef void* (*il2cpp_string_new_t)(const char* str);

// Các con trỏ hàm từ game
static void* (*PlayerData_get_Instance)() = NULL;
static void (*SetGold)(void* instance, int32_t gold) = NULL;
static void (*SetMaxHP)(void* instance, int32_t hp, bool heal, int32_t type) = NULL;
static void (*ApplyDamageReductionBuff)(void* instance, void* id, float reduction, float duration, int32_t stack, bool permanent) = NULL;
static void (*ApplySuperArmorBuff)(void* instance, void* id, float duration, int32_t stack, bool permanent) = NULL;
static void (*ApplyDamageNullifyBuff)(void* instance, void* id, float chance, float duration, int32_t stack, bool permanent) = NULL;
static void (*SetCriticalChanceMore)(void* instance, void* key, float value) = NULL;
static void (*SetSkillCoolHasteSkill)(void* instance, void* key, int32_t value) = NULL;

static il2cpp_string_new_t il2cpp_string_new = NULL;

// Hàm thực thi buff
static void applyAllCheats(void* playerDataInstance) {
    if (!playerDataInstance) return;
    
    NSLog(@"[DSSlasherCheat] 🔄 Found PlayerData Instance! Applying cheats...");
    
    if (SetGold) SetGold(playerDataInstance, 99999999);
    if (SetMaxHP) SetMaxHP(playerDataInstance, 30, true, 0);
    
    if (il2cpp_string_new) {
        void* str1 = il2cpp_string_new("god_mode");
        if (ApplyDamageReductionBuff) ApplyDamageReductionBuff(playerDataInstance, str1, 0.99f, 99999.0f, 1, true);
        
        void* str2 = il2cpp_string_new("super_armor");
        if (ApplySuperArmorBuff) ApplySuperArmorBuff(playerDataInstance, str2, 99999.0f, 1, true);
        
        void* str3 = il2cpp_string_new("nullify_buff");
        if (ApplyDamageNullifyBuff) ApplyDamageNullifyBuff(playerDataInstance, str3, 1.0f, 99999.0f, 1, true);
        
        void* str4 = il2cpp_string_new("crit_more");
        if (SetCriticalChanceMore) SetCriticalChanceMore(playerDataInstance, str4, 100.0f);
        
        void* str5 = il2cpp_string_new("cooldown_haste");
        if (SetSkillCoolHasteSkill) SetSkillCoolHasteSkill(playerDataInstance, str5, 100);
    }
    
    NSLog(@"[DSSlasherCheat] ✅ Cheats applied successfully!");
}

// Thread chạy ngầm để đợi game load xong class và instance
void* cheat_thread(void* arg) {
    NSLog(@"[DSSlasherCheat] Thread started - Waiting for UnityFramework...");
    
    void* il2cpp = NULL;
    // Vòng lặp chờ UnityFramework được nạp vào bộ nhớ
    while (!il2cpp) {
        il2cpp = dlopen("UnityFramework", RTLD_NOW);
        if (!il2cpp) il2cpp = dlopen("/System/Library/Frameworks/UnityFramework.framework/UnityFramework", RTLD_NOW);
        if (!il2cpp) usleep(500000); // Ngủ 0.5 giây nếu chưa tìm thấy
    }

    NSLog(@"[DSSlasherCheat] UnityFramework found! Loading symbols...");

    il2cpp_get_class_t getClass = (il2cpp_get_class_t)dlsym(il2cpp, "il2cpp_class_from_name");
    il2cpp_class_get_method_from_name_t getMethod = (il2cpp_class_get_method_from_name_t)dlsym(il2cpp, "il2cpp_class_get_method_from_name");
    il2cpp_string_new = (il2cpp_string_new_t)dlsym(il2cpp, "il2cpp_string_new");

    if (!getClass || !getMethod) {
        NSLog(@"[DSSlasherCheat] ❌ Failed to get IL2CPP symbols!");
        return NULL;
    }

    void* klass = NULL;
    // Chờ cho đến khi Class PlayerData được tạo ra trong bộ nhớ game
    while (!klass) {
        klass = getClass("", "PlayerData");
        if (!klass) usleep(500000);
    }

    // Lấy method get_Instance để tìm địa chỉ Object
    struct MethodInfo* mInstance = getMethod(klass, "get_Instance", 0);
    if (mInstance && mInstance->methodPointer) {
        PlayerData_get_Instance = (void*(*)())mInstance->methodPointer;
    }

    if (!PlayerData_get_Instance) {
        NSLog(@"[DSSlasherCheat] ❌ Cannot find get_Instance method!");
        return NULL;
    }

    // Gán địa chỉ cho các hàm cheat khác từ MethodInfo chuẩn
    struct MethodInfo* m;
    m = getMethod(klass, "SetGold", 1); if (m) SetGold = (void(*)(void*,int32_t))m->methodPointer;
    m = getMethod(klass, "SetMaxHP", 3); if (m) SetMaxHP = (void(*)(void*,int32_t,bool,int32_t))m->methodPointer;
    m = getMethod(klass, "ApplyDamageReductionBuff", 5); if (m) ApplyDamageReductionBuff = (void(*)(void*,void*,float,float,int32_t,bool))m->methodPointer;
    m = getMethod(klass, "ApplySuperArmorBuff", 4); if (m) ApplySuperArmorBuff = (void(*)(void*,void*,float,int32_t,bool))m->methodPointer;
    m = getMethod(klass, "ApplyDamageNullifyBuff", 5); if (m) ApplyDamageNullifyBuff = (void(*)(void*,void*,float,float,int32_t,bool))m->methodPointer;
    m = getMethod(klass, "SetCriticalChanceMore", 2); if (m) SetCriticalChanceMore = (void(*)(void*,void*,float))m->methodPointer;
    m = getMethod(klass, "SetSkillCoolHasteSkill", 2); if (m) SetSkillCoolHasteSkill = (void(*)(void*,void*,int32_t))m->methodPointer;

    // Vòng lặp liên tục kiểm tra khi nào người chơi thực sự vào game (PlayerData.Instance != NULL)
    void* instance = NULL;
    while (!instance) {
        instance = PlayerData_get_Instance();
        if (!instance) {
            usleep(1000000); // Đợi thêm 1 giây nếu chưa vào sảnh/trận
        }
    }

    // Thực thi cheat
    applyAllCheats(instance);

    return NULL;
}

// Cổng kích hoạt khi tweak được inject vào IPA
__attribute__((constructor))
static void init_cheat() {
    pthread_t tid;
    pthread_create(&tid, NULL, cheat_thread, NULL);
}
