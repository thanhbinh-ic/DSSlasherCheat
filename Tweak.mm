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
static il2cpp_get_class_t il2cpp_get_class = NULL;
static il2cpp_class_get_method_from_name_t il2cpp_class_get_method_from_name = NULL;
static il2cpp_string_new_t il2cpp_string_new = NULL;

static void* (*PlayerData_get_Instance)() = NULL;

// Method pointers
static void (*SetGold)(void* instance, int32_t gold) = NULL;
static void (*SetMaxHP)(void* instance, int32_t hp, bool heal, int32_t type) = NULL;
static void (*ApplyDamageReductionBuff)(void* instance, void* id, float reduction, float duration, int32_t stack, bool permanent) = NULL;
static void (*ApplySuperArmorBuff)(void* instance, void* id, float duration, int32_t stack, bool permanent) = NULL;
static void (*ApplyDamageNullifyBuff)(void* instance, void* id, float chance, float duration, int32_t stack, bool permanent) = NULL;
static void (*SetCriticalChanceMore)(void* instance, void* key, float value) = NULL;
static void (*SetSkillCoolHasteSkill)(void* instance, void* key, int32_t value) = NULL;

static void* playerDataInstance = NULL;

// ====================== MENU STATE ======================
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
    if (self) {
        [self setupFloatingButton];
    }
    return self;
}

- (void)setupFloatingButton {
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.window.windowLevel = UIWindowLevelAlert + 1;
    self.window.backgroundColor = [UIColor clearColor];
    self.window.hidden = NO;

    self.button = [UIButton buttonWithType:UIButtonTypeSystem];
    self.button.frame = CGRectMake(20, 100, 60, 60);
    self.button.backgroundColor = [UIColor systemRedColor];
    self.button.layer.cornerRadius = 30;
    self.button.clipsToBounds = YES;
    
    [self.button setTitle:@"⚔️" forState:UIControlStateNormal];
    self.button.titleLabel.font = [UIFont systemFontOfSize:28];
    
    [self.button addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.button addGestureRecognizer:pan];
    
    [self.window addSubview:self.button];
    
    // Auto hide sau 3 giây
    [self startAutoHideTimer];
}

- (void)startAutoHideTimer {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hideButton) withObject:nil afterDelay:3.0];
}

- (void)hideButton {
    self.button.alpha = 0.1;
}

- (void)showButton {
    self.button.alpha = 1.0;
    [self startAutoHideTimer];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.button.superview];
    CGPoint newCenter = CGPointMake(gesture.view.center.x + translation.x, gesture.view.center.y + translation.y);
    
    gesture.view.center = newCenter;
    [gesture setTranslation:CGPointZero inView:self.button.superview];
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self showButton];
    }
}

- (void)buttonTapped {
    [self showButton];
    [self showMenu];
}

- (void)showMenu {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Dungeon Slasher Cheat"
                                                                   message:@"Chọn chức năng"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:godModeEnabled ? @"✅ God Mode (ON)" : @"God Mode" 
                                              style:UIAlertActionStyleDefault 
                                            handler:^(UIAlertAction * _Nonnull action) {
        godModeEnabled = !godModeEnabled;
        [self applyCheats];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:superArmorEnabled ? @"✅ Super Armor (ON)" : @"Super Armor" 
                                              style:UIAlertActionStyleDefault 
                                            handler:^(UIAlertAction * _Nonnull action) {
        superArmorEnabled = !superArmorEnabled;
        [self applyCheats];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:damageNullifyEnabled ? @"✅ Damage Nullify (ON)" : @"Damage Nullify" 
                                              style:UIAlertActionStyleDefault 
                                            handler:^(UIAlertAction * _Nonnull action) {
        damageNullifyEnabled = !damageNullifyEnabled;
        [self applyCheats];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:critEnabled ? @"✅ Critical 100% (ON)" : @"Critical 100%" 
                                              style:UIAlertActionStyleDefault 
                                            handler:^(UIAlertAction * _Nonnull action) {
        critEnabled = !critEnabled;
        [self applyCheats];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:cooldownEnabled ? @"✅ Cooldown Haste (ON)" : @"Cooldown Haste" 
                                              style:UIAlertActionStyleDefault 
                                            handler:^(UIAlertAction * _Nonnull action) {
        cooldownEnabled = !cooldownEnabled;
        [self applyCheats];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Set Gold 99M" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (SetGold && playerDataInstance) SetGold(playerDataInstance, 99999999);
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Set HP = 30" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (SetMaxHP && playerDataInstance) SetMaxHP(playerDataInstance, 30, true, 0);
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleCancel handler:nil]];

    UIViewController *topVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [topVC presentViewController:alert animated:YES completion:nil];
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

// ====================== MAIN INIT ======================
__attribute__((constructor))
static void init_cheat() {
    NSLog(@"[DSSlasherCheat] Dylib injected - Menu version");

    // Load IL2CPP
    void* il2cpp = dlopen("UnityFramework", RTLD_NOW);
    if (!il2cpp) il2cpp = dlopen("/System/Library/Frameworks/UnityFramework.framework/UnityFramework", RTLD_NOW);

    if (il2cpp) {
        il2cpp_get_class = (il2cpp_get_class_t)dlsym(il2cpp, "il2cpp_class_from_name");
        il2cpp_class_get_method_from_name = (il2cpp_class_get_method_from_name_t)dlsym(il2cpp, "il2cpp_class_get_method_from_name");
        il2cpp_string_new = (il2cpp_string_new_t)dlsym(il2cpp, "il2cpp_string_new");
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        void* klass = il2cpp_get_class("", "PlayerData");
        if (!klass) {
            NSLog(@"[DSSlasherCheat] PlayerData not found!");
            return;
        }

        // Get Instance
        MethodInfo* m = (MethodInfo*)il2cpp_class_get_method_from_name(klass, "get_Instance", 0);
        if (m) PlayerData_get_Instance = (void*(*)())m->methodPointer;

        playerDataInstance = PlayerData_get_Instance ? PlayerData_get_Instance() : NULL;
        if (!playerDataInstance) return;

        // Load methods...
        m = (MethodInfo*)il2cpp_class_get_method_from_name(klass, "SetGold", 1);
        if (m) SetGold = (void(*)(void*,int32_t))m->methodPointer;

        m = (MethodInfo*)il2cpp_class_get_method_from_name(klass, "SetMaxHP", 3);
        if (m) SetMaxHP = (void(*)(void*,int32_t,bool,int32_t))m->methodPointer;

        m = (MethodInfo*)il2cpp_class_get_method_from_name(klass, "ApplyDamageReductionBuff", 5);
        if (m) ApplyDamageReductionBuff = (void(*)(void*,void*,float,float,int32_t,bool))m->methodPointer;

        m = (MethodInfo*)il2cpp_class_get_method_from_name(klass, "ApplySuperArmorBuff", 4);
        if (m) ApplySuperArmorBuff = (void(*)(void*,void*,float,int32_t,bool))m->methodPointer;

        m = (MethodInfo*)il2cpp_class_get_method_from_name(klass, "ApplyDamageNullifyBuff", 5);
        if (m) ApplyDamageNullifyBuff = (void(*)(void*,void*,float,float,int32_t,bool))m->methodPointer;

        m = (MethodInfo*)il2cpp_class_get_method_from_name(klass, "SetCriticalChanceMore", 2);
        if (m) SetCriticalChanceMore = (void(*)(void*,void*,float))m->methodPointer;

        m = (MethodInfo*)il2cpp_class_get_method_from_name(klass, "SetSkillCoolHasteSkill", 2);
        if (m) SetSkillCoolHasteSkill = (void(*)(void*,void*,int32_t))m->methodPointer;

        // Khởi tạo Floating Button
        [[FloatingCheatButton alloc] init];

        NSLog(@"[DSSlasherCheat] ✅ Menu floating ready!");
    });

    // Gesture 3 ngón tay để hiện nút
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 6 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UITapGestureRecognizer *tripleTap = [[UITapGestureRecognizer alloc] initWithTarget:nil action:nil];
        tripleTap.numberOfTouchesRequired = 3;
        tripleTap.numberOfTapsRequired = 1;
        tripleTap.cancelsTouchesInView = NO;
        
        [[[UIApplication sharedApplication] keyWindow] addGestureRecognizer:tripleTap];
        
        // Vì target = nil, chúng ta override handler
        [tripleTap setValue:^(UIGestureRecognizer *g) {
            // Tìm và show button (cần cải tiến nếu có nhiều button)
            NSLog(@"[DSSlasherCheat] 3-finger tap detected - Showing menu button");
        } forKey:@"handler"];
    });
}
