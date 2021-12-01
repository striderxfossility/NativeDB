
public class TooltipProgessBarController extends inkLogicController {

  protected edit let m_progressFill: inkWidgetRef;

  protected edit let m_hintHolder: inkWidgetRef;

  protected edit let m_progressHolder: inkWidgetRef;

  protected edit let m_postprogressHolder: inkWidgetRef;

  protected edit let m_hintTextHolder: inkCompoundRef;

  protected edit let m_libraryPath: inkWidgetLibraryReference;

  protected edit let m_postprogressText: inkTextRef;

  private let m_isCraftable: Bool;

  private let m_isCrafted: Bool;

  public final func SetProgressState(craftingMode: CraftingMode, isCraftable: Bool) -> Void {
    switch craftingMode {
      case CraftingMode.craft:
        this.AddButtonHints(n"UI_Apply", "UI-Crafting-hold-to-craft");
        inkTextRef.SetText(this.m_postprogressText, "UI-Crafting-Crafted");
        break;
      case CraftingMode.upgrade:
        this.AddButtonHints(n"UI_Apply", "UI-Crafting-hold-to-upgrade");
        inkTextRef.SetText(this.m_postprogressText, "UI-Crafting-Upgraded");
        break;
      default:
    };
    this.m_isCraftable = isCraftable;
    inkWidgetRef.SetVisible(this.m_hintHolder, !this.m_isCrafted && this.m_isCraftable);
    inkWidgetRef.SetVisible(this.m_progressHolder, false);
    inkWidgetRef.SetVisible(this.m_postprogressHolder, this.m_isCrafted);
    if this.m_isCraftable {
      this.RegisterToGlobalInputCallback(n"OnPostOnHold", this, n"OnHold");
      this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnRelease");
    };
  }

  private final func AddButtonHints(actionName: CName, label: String) -> Void {
    let buttonHint: ref<LabelInputDisplayController>;
    inkCompoundRef.RemoveAllChildren(this.m_hintTextHolder);
    buttonHint = this.SpawnFromExternal(inkWidgetRef.Get(this.m_hintTextHolder), inkWidgetLibraryResource.GetPath(this.m_libraryPath.widgetLibrary), this.m_libraryPath.widgetItem).GetController() as LabelInputDisplayController;
    buttonHint.SetInputActionLabel(actionName, label);
  }

  protected cb func OnHold(evt: ref<inkPointerEvent>) -> Bool {
    let progress: Float = evt.GetHoldProgress();
    this.m_isCrafted = false;
    if (evt.IsAction(n"craft_item") || evt.IsAction(n"click")) && this.m_isCraftable && !this.m_isCrafted {
      inkWidgetRef.SetVisible(this.m_hintHolder, false);
      inkWidgetRef.SetVisible(this.m_progressHolder, true);
      inkWidgetRef.SetVisible(this.m_postprogressHolder, false);
      inkWidgetRef.SetScale(this.m_progressFill, new Vector2(progress, 1.00));
      if progress >= 1.00 {
        this.m_isCrafted = true;
        inkWidgetRef.SetScale(this.m_progressFill, new Vector2(0.00, 1.00));
        inkWidgetRef.SetVisible(this.m_progressHolder, false);
        inkWidgetRef.SetVisible(this.m_hintHolder, !this.m_isCrafted && this.m_isCraftable);
        inkWidgetRef.SetVisible(this.m_postprogressHolder, this.m_isCrafted);
      };
    };
  }

  protected cb func OnRelease(evt: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_progressHolder, false);
    inkWidgetRef.SetVisible(this.m_hintHolder, !this.m_isCrafted && this.m_isCraftable);
    inkWidgetRef.SetVisible(this.m_postprogressHolder, this.m_isCrafted);
    this.m_isCrafted = false;
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromGlobalInputCallback(n"OnPostOnHold", this, n"OnHold");
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnRelease");
  }
}
