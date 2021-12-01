
public class NetworkMinigameBufferController extends inkLogicController {

  protected edit let m_bufferSlotsContainer: inkWidgetRef;

  protected edit let m_elementLibraryName: CName;

  public let m_slotList: array<wref<NetworkMinigameElementController>>;

  public edit let m_blinker: inkWidgetRef;

  private let m_count: Int32;

  private let m_AnimProxy: ref<inkAnimProxy>;

  private let m_AnimOptions: inkAnimOptions;

  private let m_alpha_fadein: ref<inkAnimDef>;

  private let currentAlpha: Float;

  private let nextAlpha: Float;

  public final func Spawn(size: Int32) -> Void {
    let alphaInterpolator: ref<inkAnimTransparency>;
    let newMargin: inkMargin;
    let slot: wref<inkWidget>;
    let slotLogic: wref<NetworkMinigameElementController>;
    this.m_count = 1;
    let i: Int32 = 0;
    while i < size {
      slot = this.SpawnFromLocal(inkWidgetRef.Get(this.m_bufferSlotsContainer), this.m_elementLibraryName);
      slotLogic = slot.GetController() as NetworkMinigameElementController;
      slotLogic.SetAsBufferSlot();
      ArrayPush(this.m_slotList, slotLogic);
      i += 1;
    };
    newMargin.left = Cast(50 * this.m_count);
    newMargin.top = 11.00;
    inkWidgetRef.SetMargin(this.m_blinker, newMargin);
    this.currentAlpha = 0.00;
    this.nextAlpha = 1.00;
    this.m_alpha_fadein = new inkAnimDef();
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetStartDelay(0.50);
    alphaInterpolator.SetDuration(0.20);
    alphaInterpolator.SetStartTransparency(this.currentAlpha);
    alphaInterpolator.SetEndTransparency(this.nextAlpha);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_alpha_fadein.AddInterpolator(alphaInterpolator);
    this.m_AnimOptions.playReversed = false;
    this.m_AnimOptions.executionDelay = 0.00;
    this.m_AnimOptions.loopType = inkanimLoopType.Cycle;
    this.m_AnimOptions.loopCounter = 1u;
    this.m_AnimProxy = inkWidgetRef.PlayAnimationWithOptions(this.m_blinker, this.m_alpha_fadein, this.m_AnimOptions);
    this.m_AnimProxy.RegisterToCallback(inkanimEventType.OnEndLoop, this, n"OnEndLoop");
  }

  public final func SetEntries(toSet: array<ElementData>) -> Void {
    let buffLoc: Float;
    let empity: ElementData;
    let newMargin: inkMargin;
    let i: Int32 = 0;
    while i < ArraySize(this.m_slotList) {
      this.m_slotList[i].SetContent(i < ArraySize(toSet) ? toSet[i] : empity);
      i += 1;
    };
    this.m_count += 1;
    if this.m_count == 2 {
      buffLoc = 165.00;
    };
    if this.m_count == 3 {
      buffLoc = 270.00;
    };
    if this.m_count == 4 {
      buffLoc = 385.00;
    };
    if this.m_count == 5 {
      buffLoc = 495.00;
    };
    if this.m_count == 6 {
      buffLoc = 605.00;
    };
    newMargin.left = buffLoc;
    newMargin.top = 11.00;
    inkWidgetRef.SetMargin(this.m_blinker, newMargin);
  }

  protected cb func OnEndLoop(proxy: ref<inkAnimProxy>) -> Bool {
    let alphaInterpolator: ref<inkAnimTransparency>;
    if this.currentAlpha == 0.00 {
      this.currentAlpha = 1.00;
      this.nextAlpha = 0.00;
    } else {
      this.currentAlpha = 0.00;
      this.nextAlpha = 1.00;
    };
    this.m_alpha_fadein = new inkAnimDef();
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetStartDelay(0.50);
    alphaInterpolator.SetDuration(0.20);
    alphaInterpolator.SetStartTransparency(this.currentAlpha);
    alphaInterpolator.SetEndTransparency(this.nextAlpha);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_alpha_fadein.AddInterpolator(alphaInterpolator);
    this.m_AnimProxy.Stop();
    this.m_AnimProxy.UnregisterFromCallback(inkanimEventType.OnEndLoop, this, n"OnEndLoop");
    this.m_AnimProxy = inkWidgetRef.PlayAnimationWithOptions(this.m_blinker, this.m_alpha_fadein, this.m_AnimOptions);
    this.m_AnimProxy.RegisterToCallback(inkanimEventType.OnEndLoop, this, n"OnEndLoop");
  }
}
