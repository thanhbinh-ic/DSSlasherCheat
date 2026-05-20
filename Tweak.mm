#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <dlfcn.h>

typedef void* (*il2cpp_get_class_t)(const char* namespaze, const char* name);
typedef void* (*il2cpp_class_get_method_from_name_t)(void* klass, const char* name, int argsCount);
typedef void* (*il2cpp_string_new_t)(const char* str);

typedef struct MethodInfo {
    void* methodPointer;
} MethodInfo;

// ====================== POINTERS ======================
static void* (*PlayerData_get_Instance)() = NULL;
static void (*SetGold)(void* instance, int32_t gold) = NULL;
static void (*SetMaxHP)(void* instance, int32_t hp, bool heal, int32_t type) = NULL;
static void (*ApplyDamageReductionBuff)(void* instance, void* id, float reduction, float duration, int32_t stack, bool permanent) = NULL;
static void (*ApplySuperArmorBuff)(void* instance, void* id, float duration, int32_t stack, bool permanent) = NULL;
static void (*ApplyDamageNullifyBuff)(void* instance, void* id, float chance, float duration, int32_t stack, bool permanent) = NULL;
static void (*SetCriticalChanceMore)(void* instance, void* key, float value) = NULL;
static void (*SetSkillCoolHasteSkill)(void* instance, void* key, int32_t value) = NULL;

static void* playerDataInstance = NULL;
static il2cpp_string_new_t il2cpp_string_new = NULL;

// ====================== APPLY CHEATS ======================
static void applyAllCheats() {
    if (!playerDataInstance) {
        NSLog(@"[DSSlasherCheat] PlayerData instance not found!");
        return;
    }

    NSLog(@"[DSSlasherCheat] Applying cheats...");

    if (SetGold) SetGold(playerDataInstance, 99999999);
    if (SetMaxHP) SetMaxHP(playerDataInstance, 30, true, 0);

    if (ApplyDamageReductionBuff) {
        void* str = il2cpp_string_new("god_mode");
        ApplyDamageReductionBuff(playerDataInstance, str, 0.99f, 99999.0f, 1, true);
    }
    if (ApplySuperArmorBuff) {
        void* str = il2cpp_string_new("super_armor");
        ApplySuperArmorBuff(playerDataInstance, str, 99999.0f, 1, true);
    }
    if (ApplyDamageNullifyBuff) {
        void* str = il2cpp_string_new("nullify_buff");
        ApplyDamageNullifyBuff(playerDataInstance, str, 1.0f, 99999.0f, 1, true);
    }
    if (SetCriticalChanceMore) {
        void* str = il2cpp_string_new("crit_more");
        SetCriticalChanceMore(playerDataInstance, str, 100.0f);
    }
    if (SetSkillCoolHasteSkill) {
        void* str = il2cpp_string_new("cooldown_haste");
        SetSkillCoolHasteSkill(playerDataInstance, str, 100);
    }

    NSLog(@"[DSSlasherCheat] All cheats applied successfully!");
}

// ====================== SIMPLE MENU ======================
static void showMenu() {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Dungeon Slasher Cheat"
                                                                   message:@"Chọn chức năng"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Apply All Cheats" 
                                              style:UIAlertActionStyleDefault 
                                            handler:^(UIAlertAction * _Nonnull action) {
        applyAllCheats();
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Đóng" 
                                              style:UIAlertActionStyleCancel 
                                            handler:nil]];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

// ====================== INIT ======================
__attribute__((constructor))
static void init_cheat() {
    NSLog(@"[DSSlasherCheat] Simple test version loaded");

    void* il2cpp = dlopen("UnityFramework", RTLD_NOW);
    if (!il2cpp) il2cpp = dlopen("/System/Library/Frameworks/UnityFramework.framework/UnityFramework", RTLD_NOW);

    if (il2cpp) {
        il2cpp_get_class_t getClass = (il2cpp_get_class_t)dlsym(il2cpp, "il2cpp_class_from_name");
        il2cpp_class_get_method_from_name_t getMethod = (il2cpp_class_get_method_from_name_t)dlsym(il2cpp, "il2cpp_class_get_method_from_name");
        il2cpp_string_new = (il2cpp_string_new_t)dlsym(il2cpp, "il2cpp_string_new");

        if (getClass && getMethod) {
            void* klass = getClass("", "PlayerData");
            if (klass) {
                MethodInfo* m = (MethodInfo*)getMethod(klass, "get_Instance", 0);
                if (m && m->methodPointer) PlayerData_get_Instance = (void*(*)())m->methodPointer;

                playerDataInstance = PlayerData_get_Instance ? PlayerData_get_Instance() : NULL;

                if (playerDataInstance) {
                    // Load methods
                    m = (MethodInfo*)getMethod(klass, "SetGold", 1); if (m) SetGold = (void(*)(void*,int32_t))m->methodPointer;
                    m = (MethodInfo*)getMethod(klass, "SetMaxHP", 3); if (m) SetMaxHP = (void(*)(void*,int32_t,bool,int32_t))m->methodPointer;
                    m = (MethodInfo*)getMethod(klass, "ApplyDamageReductionBuff", 5); if (m) ApplyDamageReductionBuff = (void(*)(void*,void*,float,float,int32_t,bool))m->methodPointer;
                    m = (MethodInfo*)getMethod(klass, "ApplySuperArmorBuff", 4); if (m) ApplySuperArmorBuff = (void(*)(void*,void*,float,int32_t,bool))m->methodPointer;
                    m = (MethodInfo*)getMethod(klass, "ApplyDamageNullifyBuff", 5); if (m) ApplyDamageNullifyBuff = (void(*)(void*,void*,float,float,int32_t,bool))m->methodPointer;
                    m = (MethodInfo*)getMethod(klass, "SetCriticalChanceMore", 2); if (m) SetCriticalChanceMore = (void(*)(void*,void*,float))m->methodPointer;
                    m = (MethodInfo*)getMethod(klass, "SetSkillCoolHasteSkill", 2); if (m) SetSkillCoolHasteSkill = (void(*)(void*,void*,int32_t))m->methodPointer;

                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        applyAllCheats();
                        NSLog(@"[DSSlasherCheat] Double tap màn hình để mở menu");
                    });
                }
            }
        }
    }

    // Double tap để mở menu
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 6 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:nil action:nil];
        doubleTap.numberOfTapsRequired = 2;
        [[UIApplication sharedApplication].keyWindow addGestureRecognizer:doubleTap];
        
        // Simple handler
        NSLog(@"[DSSlasherCheat] Double tap gesture added");
    });
}
