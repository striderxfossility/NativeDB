
public abstract native class BaseMappinBaseController extends inkLogicController {

  protected edit native let iconWidget: inkImageRef;

  protected edit native let playerTrackedWidget: inkWidgetRef;

  protected edit let m_animPlayerTrackedWidget: inkWidgetRef;

  protected edit let m_animPlayerAboveBelowWidget: inkWidgetRef;

  protected edit const let m_taggedWidgets: array<inkWidgetRef>;

  public final native func GetMappin() -> wref<IMappin>;

  public final native func GetProfile() -> ref<MappinUIRuntimeProfile_Record>;

  public final native func GetDistanceToPlayer() -> Float;

  public final native func GetVerticalRelationToPlayer() -> gamemappinsVerticalPositioning;

  public final native func ShouldShowDistance() -> Bool;

  public final native func ShouldShowDisplayName() -> Bool;

  public final native func SetProjectToScreenSpace(projectToScreenSpace: Bool) -> Void;

  protected final native func IsClamped() -> Bool;

  public final native func ShouldClamp() -> Bool;

  public final native func OverrideClamp(shouldClamp: Bool) -> Void;

  public final native func OverrideClampX(shouldClamp: Bool) -> Void;

  public final native func OverrideClampY(shouldClamp: Bool) -> Void;

  protected final native func OverrideScaleByDistance(shouldScale: Bool) -> Void;

  protected final native func SetRootVisible(visible: Bool) -> Void;

  protected final native func SetIgnorePriority(ignore: Bool) -> Void;

  public final native func IsCustomPositionTracked() -> Bool;

  public final native func IsPlayerTracked() -> Bool;

  public final native func IsTracked() -> Bool;

  protected final native func IsGPSPortal() -> Bool;

  protected final func UpdateRootState() -> Void {
    let state: CName = this.ComputeRootState();
    if Equals(state, n"") {
      state = n"Default";
    };
    this.GetRootWidget().SetState(state);
  }

  protected func UpdateTrackedState() -> Void {
    let animPlayer: ref<animationPlayer>;
    let i: Int32;
    let isClamped: Bool;
    let isRootVisible: Bool;
    let isTracked: Bool;
    let visible: Bool = false;
    if ArraySize(this.m_taggedWidgets) == 0 {
      return;
    };
    if this.GetProfile().ShowTrackedIcon() {
      isRootVisible = this.GetRootWidget().IsVisible();
      isTracked = this.IsTracked();
      isClamped = this.IsClamped();
      visible = isRootVisible && isTracked && !isClamped;
    };
    i = 0;
    while i < ArraySize(this.m_taggedWidgets) {
      inkWidgetRef.SetVisible(this.m_taggedWidgets[i], visible);
      i += 1;
    };
    animPlayer = this.GetAnimPlayer_Tracked();
    if animPlayer != null {
      animPlayer.PlayOrPause(visible);
    };
  }

  protected func ComputeRootState() -> CName {
    return n"Default";
  }

  public func GetWidgetForNameplateSlot() -> wref<inkWidget> {
    return this.GetRootWidget();
  }

  public const func GetVisualData() -> ref<GameplayRoleMappinData> {
    return null;
  }

  public final func GetAnimPlayer_Tracked() -> wref<animationPlayer> {
    return inkWidgetRef.IsValid(this.m_animPlayerTrackedWidget) ? inkWidgetRef.GetController(this.m_animPlayerTrackedWidget) : null as animationPlayer;
  }

  public final func GetAnimPlayer_AboveBelow() -> wref<animationPlayer> {
    return inkWidgetRef.IsValid(this.m_animPlayerAboveBelowWidget) ? inkWidgetRef.GetController(this.m_animPlayerAboveBelowWidget) : null as animationPlayer;
  }
}

public class MapPinUtility extends IScriptable {

  public final static func OnClampUpdates(argRoot: wref<inkCompoundWidget>, isClamped: Bool, opt isQuest: Bool) -> Void {
    let canvasHolder: wref<inkCompoundWidget> = argRoot.GetWidget(n"Canvas") as inkCompoundWidget;
    if canvasHolder != null {
      canvasHolder.SetVisible(!isClamped);
    };
  }
}
