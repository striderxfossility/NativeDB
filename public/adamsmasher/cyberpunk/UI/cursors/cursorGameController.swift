
public class CursorRootController extends inkLogicController {

  public edit let m_mainCursor: inkWidgetRef;

  public edit let m_progressBar: inkWidgetRef;

  public edit let m_progressBarFrame: inkWidgetRef;

  protected let m_animProxy: ref<inkAnimProxy>;

  public final func PlayAnim(context: CName, animationOverride: CName) -> Void {
    let animation: CName;
    if IsDefined(this.m_animProxy) {
      this.m_animProxy.GotoEndAndStop(true);
      this.m_animProxy = null;
    };
    if NotEquals(animationOverride, n"") {
      animation = this.GetAnimNameFromContext(animationOverride);
    } else {
      animation = this.GetAnimNameFromContext(context);
    };
    if NotEquals(animation, n"") {
      this.m_animProxy = this.PlayLibraryAnimation(animation);
    };
    if IsDefined(this.m_animProxy) {
      this.m_animProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationFinished");
    };
  }

  protected func GetAnimNameFromContext(context: CName) -> CName {
    return n"";
  }

  protected cb func OnAnimationFinished(proxy: ref<inkAnimProxy>) -> Bool {
    this.m_animProxy = null;
  }
}

public class GamepadCursorRootController extends CursorRootController {

  protected func GetAnimNameFromContext(context: CName) -> CName {
    let animation: CName;
    switch context {
      case n"Show":
        animation = n"show";
        break;
      case n"Hide":
        animation = n"hide";
        break;
      case n"Default":
        animation = n"default";
        break;
      case n"Hover":
        animation = n"hover";
        break;
      case n"hoverOnHoldToComplete":
        animation = n"hoverOnHoldToComplete";
        break;
      case n"InvalidAction":
        animation = n"invalid";
    };
    return animation;
  }
}

public class MouseCursorRootController extends CursorRootController {

  protected func GetAnimNameFromContext(context: CName) -> CName {
    let animation: CName;
    switch context {
      case n"Show":
        animation = n"show_mouse";
        break;
      case n"Hide":
        animation = n"hide_mouse";
        break;
      case n"Default":
        animation = n"default_mouse";
        break;
      case n"Hover":
        animation = n"hover_mouse";
        break;
      case n"hoverOnHoldToComplete":
        animation = n"hoverOnHoldToComplete_mouse";
        break;
      case n"InvalidAction":
        animation = n"invalid_mouse";
    };
    return animation;
  }
}

public class CursorGameController extends inkGameController {

  private let m_cursorRoot: wref<CursorRootController>;

  private let m_currentContext: CName;

  private let m_margin: inkMargin;

  private let m_data: ref<MenuCursorUserData>;

  @default(CursorGameController, false)
  private let m_isCursorVisible: Bool;

  protected cb func OnInitialize() -> Bool {
    let root: ref<inkWidget> = this.GetRootWidget();
    root.RegisterToCallback(n"OnSetCursorVisibility", this, n"OnSetCursorVisibility");
    root.RegisterToCallback(n"OnSetCursorPosition", this, n"OnSetCursorPosition");
    root.RegisterToCallback(n"OnSetCursorContext", this, n"OnSetCursorContext");
    root.RegisterToCallback(n"OnSetCursorType", this, n"OnSetCursorType");
    this.RegisterToGlobalInputCallback(n"OnPostOnHold", this, n"OnHold");
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnRelease");
    this.m_isCursorVisible = false;
  }

  protected cb func OnUnitialize() -> Bool {
    let root: ref<inkWidget> = this.GetRootWidget();
    root.UnregisterFromCallback(n"OnSetCursorVisibility", this, n"OnSetCursorVisibility");
    root.UnregisterFromCallback(n"OnSetCursorPosition", this, n"OnSetCursorPosition");
    root.UnregisterFromCallback(n"OnSetCursorContext", this, n"OnSetCursorContext");
    root.UnregisterFromCallback(n"OnSetCursorType", this, n"OnSetCursorType");
    this.UnregisterFromGlobalInputCallback(n"OnPostOnHold", this, n"OnHold");
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnRelease");
  }

  protected cb func OnSetCursorVisibility(isVisible: Bool) -> Bool {
    if NotEquals(this.m_isCursorVisible, isVisible) {
      this.m_isCursorVisible = isVisible;
      if this.m_isCursorVisible {
        this.ProcessCursorContext(n"Show", null);
      } else {
        this.ProcessCursorContext(n"Hide", null);
      };
    };
  }

  protected cb func OnSetCursorPosition(const pos: Vector2) -> Bool {
    this.m_margin.left = pos.X;
    this.m_margin.top = pos.Y;
    if IsDefined(this.m_cursorRoot) {
      inkWidgetRef.SetMargin(this.m_cursorRoot.m_mainCursor, this.m_margin);
    };
  }

  protected cb func OnSetCursorContext(const context: CName, data: ref<inkUserData>) -> Bool {
    this.ProcessCursorContext(context, data);
  }

  protected cb func OnSetCursorType(const type: CName) -> Bool {
    let spawnData: ref<CursorSpawnData> = new CursorSpawnData();
    spawnData.m_cursorType = type;
    if NotEquals(spawnData.m_cursorType, n"mouse") && NotEquals(spawnData.m_cursorType, n"default") {
      spawnData.m_cursorType = n"gamepad";
    };
    this.AsyncSpawnFromLocal(this.GetRootWidget(), spawnData.m_cursorType, this, n"OnCursorSpawned", spawnData);
  }

  protected cb func OnCursorSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let cursorVisibilityInfo: ref<inkCursorInfo>;
    let spawnData: wref<CursorSpawnData> = userData as CursorSpawnData;
    let root: ref<inkCompoundWidget> = this.GetRootWidget() as inkCompoundWidget;
    if IsDefined(this.m_cursorRoot) {
      root.RemoveChild(this.m_cursorRoot.GetRootWidget());
    };
    this.m_cursorRoot = widget.GetController() as CursorRootController;
    cursorVisibilityInfo = root.GetUserData(n"inkCursorInfo") as inkCursorInfo;
    cursorVisibilityInfo.SetSize(Equals(spawnData.m_cursorType, n"mouse") || !IsDefined(this.m_cursorRoot) ? new Vector2(0.00, 0.00) : inkWidgetRef.GetSize(this.m_cursorRoot.m_mainCursor));
    this.OnSetCursorVisibility(cursorVisibilityInfo.isVisible);
    this.OnSetCursorPosition(cursorVisibilityInfo.pos);
    this.ProcessCursorContext(this.m_currentContext, null, true);
  }

  protected cb func OnHold(evt: ref<inkPointerEvent>) -> Bool {
    let progress: Float = evt.GetHoldProgress();
    if progress >= 1.00 {
      return false;
    };
    if this.m_data == null {
      return false;
    };
    if this.DoesActionMatch(evt, this.m_data.GetActions()) {
      this.UpdateFillPercent(progress);
    };
  }

  protected cb func OnRelease(evt: ref<inkPointerEvent>) -> Bool {
    let actionsList: array<CName>;
    if IsDefined(this.m_data) {
      actionsList = this.m_data.GetActions();
    };
    if this.DoesActionMatch(evt, actionsList) {
      this.UpdateFillPercent(0.00);
    };
  }

  public final func UpdateFillPercent(percent: Float) -> Void {
    let newScale: Vector2;
    newScale.X = percent;
    newScale.Y = 1.00;
    if IsDefined(this.m_cursorRoot) {
      if inkWidgetRef.IsValid(this.m_cursorRoot.m_progressBarFrame) {
        inkWidgetRef.SetVisible(this.m_cursorRoot.m_progressBarFrame, percent > 0.00);
      };
      inkWidgetRef.SetScale(this.m_cursorRoot.m_progressBar, newScale);
    };
  }

  private final func ProcessCursorContext(const context: CName, data: ref<inkUserData>, opt force: Bool) -> Void {
    let animationOverride: CName;
    if NotEquals(this.m_currentContext, context) || this.m_data != data || force {
      this.m_currentContext = context;
      this.m_data = data as MenuCursorUserData;
      if IsDefined(this.m_data) {
        animationOverride = this.m_data.GetAnimationOverride();
      };
      this.UpdateFillPercent(0.00);
      if IsDefined(this.m_cursorRoot) {
        this.m_cursorRoot.PlayAnim(context, animationOverride);
      };
      if Equals(context, n"Hover") {
        GameInstance.GetAudioSystem(this.GetPlayerControlledObject().GetGame()).Play(n"ui_menu_hover");
      };
    };
  }

  private final func DoesActionMatch(evt: ref<inkPointerEvent>, actionsList: array<CName>) -> Bool {
    let i: Int32;
    let count: Int32 = ArraySize(actionsList);
    if Cast(count) {
      i = 0;
      while i < count {
        if evt.IsAction(actionsList[i]) {
          return true;
        };
        i += 1;
      };
    };
    return false;
  }
}

public class MenuCursorUserData extends inkUserData {

  private let animationOverride: CName;

  private let actions: array<CName>;

  public final func SetAnimationOverride(anim: CName) -> Void {
    this.animationOverride = anim;
  }

  public final func GetAnimationOverride() -> CName {
    return this.animationOverride;
  }

  public final func AddAction(action: CName) -> Void {
    ArrayPush(this.actions, action);
  }

  public final func GetActions() -> array<CName> {
    return this.actions;
  }

  public final func GetActionsListSize() -> Int32 {
    return ArraySize(this.actions);
  }
}
