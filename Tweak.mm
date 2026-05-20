#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <dlfcn.h>

typedef void* (*il2cpp_get_class_t)(const char* namespaze, const char* name);
typedef void* (*il2cpp_class_get_method_from_name_t)(void* klass, const char* name, int argsCount);
typedef void* (*il2cpp_string_new_t)(const char* str);

typedef struct MethodInfo {
    void* methodPointer;
} MethodInfo;

// IL2CPP Function Pointers
static il2cpp_get_class_t il2cpp_get_class = NULL;
static il2cpp_class_get_method_from_name_t il2cpp_class_get_method_from_name = NULL;
static il2cpp_string_new_t il2cpp_string_new = NULL;

static void* (*PlayerData_get_Instance)() = NULL;

static void (*SetGold)(void* instance, int32_t gold) = NULL;
static void (*SetMaxHP)(void* instance, int32_t hp, bool heal, int32_t type) = NULL;
static void (*ApplyDamageReductionBuff)(void* instance, void* id, float reduction, float duration, int32_t stack, bool permanent) = NULL;
static void (*ApplySuperArmorBuff)(void* instance, void* id, float duration, int32_t stack, bool permanent) = NULL;
static void (*ApplyDamageNullifyBuff)(void* instance, void* id, float chance, float duration, int32_t stack, bool permanent) = NULL;
static void (*SetCriticalChanceMore)(void* instance, void* key, float value) = NULL;
static void (*SetSkillCoolHasteSkill)(void* instance, void* key, int32_t value) = NULL;

static void* playerDataInstance = NULL;

// Menu State
static BOOL godModeEnabled = YES;
static BOOL superArmorEnabled = YES;
static BOOL damageNullifyEnabled = YES;
static BOOL critEnabled = YES;
static BOOL cooldownEnabled = YES;

// ====================== FLOATING BUTTON ======================
@interface FloatingCheatButton : NSObject
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIWindow *window;
@end

@implementation FloatingCheatButton

- (instancetype)init {
    self = [super init];
    if (self) [self setupUI];
    return self;
}

- (void)setupUI {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.windowLevel = UIWindowLevelAlert + 100;
    self.window.backgroundColor = [UIColor clearColor];
    self.window.hidden = NO;

    self.button = [UIButton buttonWithType:UIButtonTypeSystem];
    self.button.frame = CGRectMake(30, 150, 65, 65);
    self.button.backgroundColor = [UIColor systemRedColor];
    self.button.layer.cornerRadius = 32.5;
    [self.button setTitle:@"⚔️" forState:UIControlStateNormal];
    self.button.titleLabel.font = [UIFont systemFontOfSize:32 weight:UIFontWeightBold];

    [self.button addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.button addGestureRecognizer:pan];

    [self.window addSubview:self.button];
    [self startAutoHide];
}

- (void)startAutoHide {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hideButton) withObject:nil afterDelay:3.0];
}

- (void)hideButton {
    [UIView animateWithDuration:0.3 animations:^{
        self.button.alpha = 0.15;
    }];
}

- (void)showButton {
    [UIView animateWithDuration:0.3 animations:^{
        self.button.alpha = 1.0;
    }];
    [self startAutoHide];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:gesture.view];
    gesture.view.center = CGPointMake(gesture.view.center.x + translation.x, gesture.view.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:gesture.view];
    
    if (gesture.state == UIGestureRecognizerStateEnded) [self showButton];
}

- (void)buttonTapped {
    [self showButton];
    [self showMenu];
}

- (void)showMenu {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Dungeon Slasher Cheat"
                                                                   message:@"Bật / Tắt chức năng"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:godModeEnabled ? @"✅ God Mode" : @"God Mode" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a){ godModeEnabled = !godModeEnabled; [self applyCheats]; }]];
    [alert addAction:[UIAlertAction actionWithTitle:superArmorEnabled ? @"✅ Super Armor" : @"Super Armor" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a){ superArmorEnabled = !superArmorEnabled; [self applyCheats]; }]];
    [alert addAction:[UIAlertAction actionWithTitle:damageNullifyEnabled ? @"✅ Damage Nullify" : @"Damage Nullify" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a){ damageNullifyEnabled = !damageNullifyEnabled; [self applyCheats]; }]];
    [alert addAction:[UIAlertAction actionWithTitle:critEnabled ? @"✅ Critical 100%" : @"Critical 100%" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a){ critEnabled = !critEnabled; [self applyCheats]; }]];
    [alert addAction:[UIAlertAction actionWithTitle:cooldownEnabled ? @"✅ Cooldown Haste" : @"Cooldown Haste" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a){ cooldownEnabled = !cooldownEnabled; [self applyCheats]; }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"💰 Set Gold 99M" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a){
        if (SetGold && playerDataInstance) SetGold(playerDataInstance, 99999999);
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"❤️ Set HP = 30" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a){
        if (SetMaxHP && playerDataInstance) SetMaxHP(playerDataInstance, 30, true, 0);
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleCancel handler:nil]];

    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (void)applyCheats {
    if (!playerDataInstance) return;
    
    if (godModeEnabled && ApplyDamageReductionBuff) {
        void* str = il2cpp_string_new("god_mode");
        ApplyDamageReductionBuff(playerDataInstance, str, 0.99f, 99999.0f, 1, true);
    }
    if (superArmorEnabled && ApplySuperArmorBuff) {
        void* str = il2cpp_string_new("super_armor");
        ApplySuperArmorBuff(playerDataInstance, str, 99999.0f, 1, true);
    }
    if (damageNullifyEnabled && ApplyDamageNullifyBuff) {
        void* str = il2cpp_string_new("nullify_buff");
        ApplyDamageNullifyBuff(playerDataInstance, str, 1.0f, 99999.0f, 1, true);
    }
    if (critEnabled && SetCriticalChanceMore) {
        void* str = il2cpp_string_new("crit_more");
        SetCriticalChanceMore(playerDataInstance, str, 100.0f);
    }
    if (cooldownEnabled && SetSkillCoolHasteSkill) {
        void* str = il2cpp_string_new("cooldown_haste");
        SetSkillCoolHasteSkill(playerDataInstance, str, 100);
    }
}

@end

// ====================== INIT ======================
__attribute__((constructor))
static void init_cheat() {
    NSLog(@"[DSSlasherCheat] Menu version injected");

    void* il2cpp = dlopen("UnityFramework", RTLD_NOW);
    if (!il2cpp) il2cpp = dlopen("/System/Library/Frameworks/UnityFramework.framework/UnityFramework", RTLD_NOW);

    if (il2cpp) {
        il2cpp_get_class = (il2cpp_get_class_t)dlsym(il2cpp, "il2cpp_class_from_name");
        il2cpp_class_get_method_from_name = (il2cpp_class_get_method_from_name_t)dlsym(il2cpp, "il2cpp_class_get_method_from_name");
        il2cpp_string_new = (il2cpp_string_new_t)dlsym(il2cpp, "il2cpp_string_new");
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        void* klass = il2cpp_get_class ? il2cpp_get_class("", "PlayerData") : NULL;
        if (!klass) return;

        MethodInfo* m = (MethodInfo*)il2cpp_class_get_method_from_name(klass, "get_Instance", 0);
        if (m) PlayerData_get_Instance = (void*(*)())m->methodPointer;

        playerDataInstance = PlayerData_get_Instance ? PlayerData_get_Instance() : NULL;
        if (!playerDataInstance) return;

        // Load methods
        m = (MethodInfo*)il2cpp_class_get_method_from_name(klass, "SetGold", 1); if (m) SetGold = (void(*)(void*,int32_t))m->methodPointer;
        m = (MethodInfo*)il2cpp_class_get_method_from_name(klass, "SetMaxHP", 3); if (m) SetMaxHP = (void(*)(void*,int32_t,bool,int32_t))m->methodPointer;
        m = (MethodInfo*)il2cpp_class_get_method_from_name(klass, "ApplyDamageReductionBuff", 5); if (m) ApplyDamageReductionBuff = (void(*)(void*,void*,float,float,int32_t,bool))m->methodPointer;
        m = (MethodInfo*)il2cpp_class_get_method_from_name(klass, "ApplySuperArmorBuff", 4); if (m) ApplySuperArmorBuff = (void(*)(void*,void*,float,int32_t,bool))m->methodPointer;
        m = (MethodInfo*)il2cpp_class_get_method_from_name(klass, "ApplyDamageNullifyBuff", 5); if (m) ApplyDamageNullifyBuff = (void(*)(void*,void*,float,float,int32_t,bool))m->methodPointer;
        m = (MethodInfo*)il2cpp_class_get_method_from_name(klass, "SetCriticalChanceMore", 2); if (m) SetCriticalChanceMore = (void(*)(void*,void*,float))m->methodPointer;
        m = (MethodInfo*)il2cpp_class_get_method_from_name(klass, "SetSkillCoolHasteSkill", 2); if (m) SetSkillCoolHasteSkill = (void(*)(void*,void*,int32_t))m->methodPointer;

        [[FloatingCheatButton alloc] init];
        NSLog(@"[DSSlasherCheat] Floating Menu ready! (3-finger tap to show if hidden)");
    });
}
