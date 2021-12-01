
public class KeyboardHintItemController extends AHintItemController {

  private edit let m_NumberText: inkTextRef;

  private edit let m_Frame: inkImageRef;

  @default(KeyboardHintItemController, Disabled)
  private edit let m_DisabledStateName: CName;

  @default(KeyboardHintItemController, Selected)
  private edit let m_SelectedStateName: CName;

  @default(KeyboardHintItemController, top_button_selected)
  private edit let m_FrameSelectedName: CName;

  @default(KeyboardHintItemController, top_button)
  private edit let m_FrameUnselectedName: CName;

  @default(KeyboardHintItemController, AnimRootOnThenOff)
  private edit let m_AnimationName: CName;

  public final func Setup(itemNumber: Int32) -> Void {
    inkTextRef.SetText(this.m_NumberText, IntToString(itemNumber));
  }

  protected func CacheAnimations() -> Void;

  public final func SetState(isEnabled: Bool, isSelected: Bool) -> Void {
    if isEnabled {
      this.m_Root.SetState(isSelected ? this.m_SelectedStateName : inkWidget.DefaultState());
    } else {
      this.m_Root.SetState(this.m_DisabledStateName);
    };
    inkImageRef.SetTexturePart(this.m_Frame, isEnabled && isSelected ? this.m_FrameSelectedName : this.m_FrameUnselectedName);
  }

  public func Animate(isEnabled: Bool) -> Void {
    this.Animate(isEnabled);
    if isEnabled {
      inkWidgetRef.SetOpacity(this.m_Icon, 1.00);
    } else {
      inkWidgetRef.SetOpacity(this.m_Icon, 0.40);
    };
    this.PlayLibraryAnimationOnTargets(this.m_AnimationName, SelectWidgets(this.m_Root));
  }
}

public abstract class AHintItemController extends inkLogicController {

  protected edit let m_Icon: inkImageRef;

  protected edit let m_UnavaliableText: inkTextRef;

  protected let m_Root: wref<inkWidget>;

  protected cb func OnInitialize() -> Bool {
    this.m_Root = this.GetRootWidget();
    this.m_Root.SetOpacity(0.00);
    this.CacheAnimations();
  }

  public final func SetIcon(atlasPath: CName, iconName: CName) -> Void {
    inkImageRef.SetTexturePart(this.m_Icon, iconName);
  }

  protected func CacheAnimations() -> Void;

  public func Animate(isEnabled: Bool) -> Void {
    inkWidgetRef.Get(this.m_UnavaliableText).SetVisible(!isEnabled);
  }

  protected func OnAnimFinished(anim: ref<inkAnimProxy>) -> Void {
    this.m_Root.SetOpacity(0.00);
  }
}
