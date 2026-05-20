#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#include <dlfcn.h>

typedef void* (*il2cpp_get_class_t)(const char* namespaze, const char* name);
typedef void* (*il2cpp_class_get_method_from_name_t)(void* klass, const char* name, int argsCount);
typedef void* (*il2cpp_string_new_t)(const char* str);

static il2cpp_get_class_t il2cpp_get_class = NULL;
static il2cpp_class_get_method_from_name_t il2cpp_class_get_method_from_name = NULL;
static il2cpp_string_new_t il2cpp_string_new = NULL;

static void* (*PlayerData_get_Instance)() = NULL;
static void (*PlayerData_SetGold)(void* instance, int32_t gold) = NULL;
static void (*PlayerData_SetMaxHP)(void* instance, int32_t hp, bool heal, int32_t type) = NULL;
static void (*PlayerData_ApplyDamageReductionBuff)(void* instance, void* id, float reduction, float duration, int32_t stack, bool permanent) = NULL;
static void (*PlayerData_ApplySuperArmorBuff)(void* instance, void* id, float duration, int32_t stack, bool permanent) = NULL;
static void (*PlayerData_ApplyDamageNullifyBuff)(void* instance, void* id, float chance, float duration, int32_t stack, bool permanent) = NULL;
static void (*PlayerData_SetCriticalChanceMore)(void* instance, void* key, float value) = NULL;
static void (*PlayerData_SetSkillCoolHasteSkill)(void* instance, void* key, int32_t value) = NULL;

__attribute__((constructor))
static void init_cheat() {
    NSLog(@"[DSSlasherCheat] Dylib loaded successfully!");

    void* il2cpp = dlopen("UnityFramework", RTLD_NOW);
    if (!il2cpp) il2cpp = dlopen("/System/Library/Frameworks/UnityFramework.framework/UnityFramework", RTLD_NOW);

    if (il2cpp) {
        il2cpp_get_class = (il2cpp_get_class_t)dlsym(il2cpp, "il2cpp_class_from_name");
        il2cpp_class_get_method_from_name = (il2cpp_class_get_method_from_name_t)dlsym(il2cpp, "il2cpp_class_get_method_from_name");
        il2cpp_string_new = (il2cpp_string_new_t)dlsym(il2cpp, "il2cpp_string_new");
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        void* playerDataClass = il2cpp_get_class ? il2cpp_get_class("", "PlayerData") : NULL;
        if (!playerDataClass) {
            NSLog(@"[DSSlasherCheat] PlayerData class not found!");
            return;
        }

        void* method = il2cpp_class_get_method_from_name(playerDataClass, "get_Instance", 0);
        if (method) PlayerData_get_Instance = (void*(*)())method->methodPointer;

        void* instance = PlayerData_get_Instance ? PlayerData_get_Instance() : NULL;
        if (!instance) {
            NSLog(@"[DSSlasherCheat] PlayerData instance not found!");
            return;
        }

        NSLog(@"[DSSlasherCheat] PlayerData found! Applying cheats...");

        // Gold
        method = il2cpp_class_get_method_from_name(playerDataClass, "SetGold", 1);
        if (method) PlayerData_SetGold = (void(*)(void*,int32_t))method->methodPointer;
        if (PlayerData_SetGold) PlayerData_SetGold(instance, 99999999);

        // Max HP
        method = il2cpp_class_get_method_from_name(playerDataClass, "SetMaxHP", 3);
        if (method) PlayerData_SetMaxHP = (void(*)(void*,int32_t,bool,int32_t))method->methodPointer;
        if (PlayerData_SetMaxHP) PlayerData_SetMaxHP(instance, 30, true, 0);

        // Damage Reduction (God Mode)
        void* str1 = il2cpp_string_new("god_mode");
        method = il2cpp_class_get_method_from_name(playerDataClass, "ApplyDamageReductionBuff", 5);
        if (method) PlayerData_ApplyDamageReductionBuff = (void(*)(void*,void*,float,float,int32_t,bool))method->methodPointer;
        if (PlayerData_ApplyDamageReductionBuff) PlayerData_ApplyDamageReductionBuff(instance, str1, 0.99f, 99999.0f, 1, true);

        // Super Armor
        void* str2 = il2cpp_string_new("super_armor");
        method = il2cpp_class_get_method_from_name(playerDataClass, "ApplySuperArmorBuff", 4);
        if (method) PlayerData_ApplySuperArmorBuff = (void(*)(void*,void*,float,int32_t,bool))method->methodPointer;
        if (PlayerData_ApplySuperArmorBuff) PlayerData_ApplySuperArmorBuff(instance, str2, 99999.0f, 1, true);

        // Damage Nullify
        void* str3 = il2cpp_string_new("nullify_buff");
        method = il2cpp_class_get_method_from_name(playerDataClass, "ApplyDamageNullifyBuff", 5);
        if (method) PlayerData_ApplyDamageNullifyBuff = (void(*)(void*,void*,float,float,int32_t,bool))method->methodPointer;
        if (PlayerData_ApplyDamageNullifyBuff) PlayerData_ApplyDamageNullifyBuff(instance, str3, 1.0f, 99999.0f, 1, true);

        // Critical
        void* str4 = il2cpp_string_new("crit_more");
        method = il2cpp_class_get_method_from_name(playerDataClass, "SetCriticalChanceMore", 2);
        if (method) PlayerData_SetCriticalChanceMore = (void(*)(void*,void*,float))method->methodPointer;
        if (PlayerData_SetCriticalChanceMore) PlayerData_SetCriticalChanceMore(instance, str4, 100.0f);

        // Cooldown
        void* str5 = il2cpp_string_new("cooldown_haste");
        method = il2cpp_class_get_method_from_name(playerDataClass, "SetSkillCoolHasteSkill", 2);
        if (method) PlayerData_SetSkillCoolHasteSkill = (void(*)(void*,void*,int32_t))method->methodPointer;
        if (PlayerData_SetSkillCoolHasteSkill) PlayerData_SetSkillCoolHasteSkill(instance, str5, 100);

        NSLog(@"[DSSlasherCheat] All cheats applied successfully!");
    });
}
