#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <dlfcn.h>

typedef void* (*il2cpp_get_class_t)(const char* namespaze, const char* name);
typedef void* (*il2cpp_class_get_method_from_name_t)(void* klass, const char* name, int argsCount);
typedef void* (*il2cpp_string_new_t)(const char* str);

typedef struct MethodInfo {
    void* methodPointer;
} MethodInfo;

// ====================== IL2CPP POINTERS ======================
static void* (*PlayerData_get_Instance)() = NULL;
static void (*SetGold)(void* instance, int32_t gold) = NULL;
static void (*SetMaxHP)(void* instance, int32_t hp, bool heal, int32_t type) = NULL;
static void (*ApplyDamageReductionBuff)(void* instance, void* id, float reduction, float duration, int32_t stack, bool permanent) = NULL;
static void (*ApplySuperArmorBuff)(void* instance, void* id, float duration, int32_t stack, bool permanent) = NULL;
static void (*ApplyDamageNullifyBuff)(void* instance, void* id, float chance, float duration, int32_t stack, bool permanent) = NULL;
static void (*SetCriticalChanceMore)(void* instance, void* key, float value) = NULL;
static void (*SetSkillCoolHasteSkill)(void* instance, void* key, int32_t value) = NULL;

static void* playerDataInstance = NULL;

// ====================== APPLY CHEATS ======================
static void applyAllCheats() {
    if (!playerDataInstance) return;
    
    NSLog(@"[DSSlasherCheat] Applying all cheats...");

    if (SetGold) SetGold(playerDataInstance, 99999999);
    if (SetMaxHP) SetMaxHP(playerDataInstance, 30, true, 0);

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

    NSLog(@"[DSSlasherCheat] All cheats applied!");
}

// ====================== SIMPLE MENU ======================
static void showSimpleMenu() {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Dungeon Slasher Cheat"
                                                                   message:@"Chọn hành động"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Apply All Cheats" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        applyAllCheats();
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Set Gold 99M" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (SetGold && playerDataInstance) SetGold(playerDataInstance, 99999999);
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Set HP = 30" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (SetMaxHP && playerDataInstance) SetMaxHP(playerDataInstance, 30, true, 0);
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleCancel handler:nil]];
    
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    [root presentViewController:alert animated:YES completion:nil];
}

// ====================== MAIN INIT ======================
__attribute__((constructor))
static void init_cheat() {
    NSLog(@"[DSSlasherCheat] Simple version loaded");

    void* il2cpp = dlopen("UnityFramework", RTLD_NOW);
    if (!il2cpp) il2cpp = dlopen("/System/Library/Frameworks/UnityFramework.framework/UnityFramework", RTLD_NOW);

    if (il2cpp) {
        il2cpp_get_class_t getClass = (il2cpp_get_class_t)dlsym(il2cpp, "il2cpp_class_from_name");
        il2cpp_class_get_method_from_name_t getMethod = (il2cpp_class_get_method_from_name_t)dlsym(il2cpp, "il2cpp_class_get_method_from_name");
        il2cpp_string_new_t newString = (il2cpp_string_new_t)dlsym(il2cpp, "il2cpp_string_new");

        if (getClass && getMethod) {
            void* klass = getClass("", "PlayerData");
            if (klass) {
                MethodInfo* m = (MethodInfo*)getMethod(klass, "get_Instance", 0);
                if (m) PlayerData_get_Instance = (void*(*)())m->methodPointer;

                playerDataInstance = PlayerData_get_Instance ? PlayerData_get_Instance() : NULL;

                // Load methods
                m = (MethodInfo*)getMethod(klass, "SetGold", 1); if (m) SetGold = (void(*)(void*,int32_t))m->methodPointer;
                m = (MethodInfo*)getMethod(klass, "SetMaxHP", 3); if (m) SetMaxHP = (void(*)(void*,int32_t,bool,int32_t))m->methodPointer;
                m = (MethodInfo*)getMethod(klass, "ApplyDamageReductionBuff", 5); if (m) ApplyDamageReductionBuff = (void(*)(void*,void*,float,float,int32_t,bool))m->methodPointer;
                m = (MethodInfo*)getMethod(klass, "ApplySuperArmorBuff", 4); if (m) ApplySuperArmorBuff = (void(*)(void*,void*,float,int32_t,bool))m->methodPointer;
                m = (MethodInfo*)getMethod(klass, "ApplyDamageNullifyBuff", 5); if (m) ApplyDamageNullifyBuff = (void(*)(void*,void*,float,float,int32_t,bool))m->methodPointer;
                m = (MethodInfo*)getMethod(klass, "SetCriticalChanceMore", 2); if (m) SetCriticalChanceMore = (void(*)(void*,void*,float))m->methodPointer;
                m = (MethodInfo*)getMethod(klass, "SetSkillCoolHasteSkill", 2); if (m) SetSkillCoolHasteSkill = (void(*)(void*,void*,int32_t))m->methodPointer;
            }
        }
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (playerDataInstance) {
            applyAllCheats();   // Auto apply khi vào game
            
            // Double tap màn hình để hiện menu
            UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:nil action:nil];
            doubleTap.numberOfTapsRequired = 2;
            doubleTap.numberOfTouchesRequired = 1;
            
            [[UIApplication sharedApplication].keyWindow addGestureRecognizer:doubleTap];
            
            NSLog(@"[DSSlasherCheat] ✅ Ready! Double tap màn hình để mở menu");
        }
    });
}
