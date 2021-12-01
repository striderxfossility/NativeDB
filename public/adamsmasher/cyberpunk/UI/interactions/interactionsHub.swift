
public class InteractionsHubGameController extends inkHUDGameController {

  private edit const let m_TopInteractionWidgetsLibraries: array<inkWidgetLibraryReference>;

  private edit let m_TopInteractionsRoot: inkWidgetRef;

  private edit const let m_BotInteractionWidgetsLibraries: array<inkWidgetLibraryReference>;

  private edit let m_BotInteractionsRoot: inkWidgetRef;

  private edit let m_TooltipsManagerRef: inkWidgetRef;

  private let m_TooltipsManager: wref<gameuiTooltipsManager>;

  protected cb func OnInitialize() -> Bool {
    let createdWidget: wref<inkWidget>;
    let libraryRef: inkWidgetLibraryReference;
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(this.m_TopInteractionWidgetsLibraries);
    while i < limit {
      libraryRef = this.m_TopInteractionWidgetsLibraries[i];
      createdWidget = this.SpawnFromExternal(inkWidgetRef.Get(this.m_TopInteractionsRoot), inkWidgetLibraryResource.GetPath(libraryRef.widgetLibrary), libraryRef.widgetItem);
      createdWidget.RegisterToCallback(n"OnTooltipRequest", this, n"OnTooltipRequest");
      i += 1;
    };
    i = 0;
    limit = ArraySize(this.m_BotInteractionWidgetsLibraries);
    while i < limit {
      libraryRef = this.m_BotInteractionWidgetsLibraries[i];
      createdWidget = this.SpawnFromExternal(inkWidgetRef.Get(this.m_BotInteractionsRoot), inkWidgetLibraryResource.GetPath(libraryRef.widgetLibrary), libraryRef.widgetItem);
      createdWidget.RegisterToCallback(n"OnTooltipRequest", this, n"OnTooltipRequest");
      i += 1;
    };
    this.m_TooltipsManager = inkWidgetRef.GetControllerByType(this.m_TooltipsManagerRef, n"gameuiTooltipsManager") as gameuiTooltipsManager;
    if IsDefined(this.m_TooltipsManager) {
      this.m_TooltipsManager.Setup(ETooltipsStyle.HUD, false);
    };
  }

  protected cb func OnRefreshTooltipEvent(e: ref<RefreshTooltipEvent>) -> Bool {
    let tooltipProvider: wref<TooltipProvider> = e.widget.GetControllerByType(n"TooltipProvider") as TooltipProvider;
    if IsDefined(tooltipProvider) && IsDefined(this.m_TooltipsManager) && tooltipProvider.IsVisible() {
      this.m_TooltipsManager.ShowTooltips(tooltipProvider.GetTooltipsData(), new inkMargin(0.00, 0.00, 0.00, 0.00), true);
    } else {
      this.m_TooltipsManager.HideTooltips();
    };
  }

  protected cb func OnInvalidateHidden(e: ref<InvalidateTooltipHiddenStateEvent>) -> Bool {
    let tooltipProvider: wref<TooltipProvider> = e.widget.GetControllerByType(n"TooltipProvider") as TooltipProvider;
    if IsDefined(tooltipProvider) && IsDefined(this.m_TooltipsManager) && !tooltipProvider.IsVisible() {
      this.m_TooltipsManager.HideTooltips();
    };
  }

  protected cb func OnTooltipRequest(e: wref<inkWidget>) -> Bool {
    let tooltipProvider: wref<TooltipProvider> = e.GetControllerByType(n"TooltipProvider") as TooltipProvider;
    if IsDefined(tooltipProvider) && IsDefined(this.m_TooltipsManager) {
      this.m_TooltipsManager.ShowTooltips(tooltipProvider.GetTooltipsData(), new inkMargin(0.00, 0.00, 0.00, 0.00), true);
    };
  }
}
