
public class textScrollingAnimController extends inkLogicController {

  public edit let m_scannerDetailsHackLog: inkTextRef;

  @default(textScrollingAnimController, 0.05f)
  public edit let m_defaultScrollSpeed: Float;

  @default(textScrollingAnimController, false)
  public edit let m_playOnInit: Bool;

  @default(textScrollingAnimController, 4)
  public edit let m_numOfLines: Int32;

  @default(textScrollingAnimController, 0)
  public edit let m_numOfStartingLines: Int32;

  @default(textScrollingAnimController, 1.0f)
  public edit let m_transparency: Float;

  @default(textScrollingAnimController, 0)
  public edit let m_gapIndex: Int32;

  @default(textScrollingAnimController, false)
  public edit let m_binaryOnly: Bool;

  @default(textScrollingAnimController, 4)
  public edit let m_binaryClusterCount: Int32;

  public edit let m_scrollingText: ScrollingText;

  private let m_logArray: array<String>;

  private let m_upload_counter: Float;

  private let m_scrollSpeed: Float;

  private let m_fastScrollSpeed: Float;

  private let m_panel: wref<inkCompoundWidget>;

  private let m_alpha_fadein: ref<inkAnimDef>;

  private let m_AnimProxy: ref<inkAnimProxy>;

  private let m_AnimOptions: inkAnimOptions;

  private let m_lineCount: Int32;

  protected cb func OnInitialize() -> Bool {
    this.m_panel.SetVisible(false);
    this.m_fastScrollSpeed = 0.05;
    ArrayResize(this.m_logArray, this.m_numOfLines + 15);
    inkTextRef.SetText(this.m_scannerDetailsHackLog, "");
    if this.m_playOnInit {
      this.StartScroll();
    };
  }

  public final func StartScroll(opt fast: Bool) -> Void {
    let alphaInterpolator: ref<inkAnimTransparency>;
    let i: Int32;
    this.m_panel.SetVisible(true);
    inkTextRef.SetText(this.m_scannerDetailsHackLog, "");
    this.m_upload_counter = 0.00;
    ArrayClear(this.m_logArray);
    ArrayResize(this.m_logArray, this.m_numOfLines + 15);
    inkWidgetRef.StopAllAnimations(this.m_scannerDetailsHackLog);
    this.m_scrollSpeed = fast ? this.m_fastScrollSpeed : this.m_defaultScrollSpeed;
    if this.m_numOfStartingLines > 0 {
      i = 0;
      while i < this.m_numOfStartingLines {
        this.m_upload_counter += 1.00;
        this.AddToHackLog(RoundF(this.m_upload_counter));
        i += 1;
      };
    };
    this.m_alpha_fadein = new inkAnimDef();
    alphaInterpolator = new inkAnimTransparency();
    alphaInterpolator.SetDuration(this.m_scrollSpeed);
    alphaInterpolator.SetStartTransparency(this.m_transparency);
    alphaInterpolator.SetEndTransparency(this.m_transparency);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    this.m_alpha_fadein.AddInterpolator(alphaInterpolator);
    this.m_AnimOptions.playReversed = false;
    this.m_AnimOptions.executionDelay = 0.00;
    this.m_AnimOptions.loopType = inkanimLoopType.Cycle;
    this.m_AnimOptions.loopInfinite = true;
    this.m_AnimProxy = inkWidgetRef.PlayAnimationWithOptions(this.m_scannerDetailsHackLog, this.m_alpha_fadein, this.m_AnimOptions);
    this.m_AnimProxy.RegisterToCallback(inkanimEventType.OnEndLoop, this, n"OnEndLoop");
  }

  public final func StopScroll() -> Void {
    this.m_AnimProxy.Stop();
    this.m_AnimProxy.UnregisterFromCallback(inkanimEventType.OnEndLoop, this, n"OnEndLoop");
    this.m_panel.SetVisible(false);
    inkTextRef.SetText(this.m_scannerDetailsHackLog, "");
    this.m_upload_counter = 0.00;
    ArrayClear(this.m_logArray);
    ArrayResize(this.m_logArray, this.m_numOfLines + 15);
    inkWidgetRef.StopAllAnimations(this.m_scannerDetailsHackLog);
  }

  private final func AddToHackLog(count: Int32) -> Void {
    let j: Int32;
    let s: String;
    let sOut: String;
    let i: Int32 = 1;
    while i < ArraySize(this.m_logArray) - 1 {
      this.m_logArray[i] = this.m_logArray[i + 1];
      i += 1;
    };
    j = 0;
    while j < this.m_binaryClusterCount {
      i = 0;
      while i < 4 {
        s = s + RoundF(RandRangeF(0.00, 2.00));
        i += 1;
      };
      s = s + " ";
      j += 1;
    };
    j = RoundF(RandRangeF(0.00, 15.00));
    if j < 6 {
      s = s + "\\n";
    };
    if this.m_gapIndex != 0 && this.m_lineCount >= this.m_gapIndex {
      this.m_lineCount = 0;
      s = "\\n\\n";
    } else {
      if this.m_binaryOnly {
        s = s + "\\n";
      } else {
        if ArraySize(this.m_scrollingText.textArray) == 0 {
          j = RoundF(RandRangeF(0.00, Cast(this.m_numOfLines)));
          if j == 0 {
            s = "Checking sent packets... Success\\n";
          };
          if j == 1 {
            s = "Clearing bufffers... Success\\n";
          };
          if j == 2 {
            s = "Resizing buffer... Success\\n";
          };
          if j == 3 {
            s = "Pinging connection... Done\\n";
          };
          if j == 4 {
            s = "Clearing logs... Done\\n";
          };
        } else {
          j = RoundF(RandRangeF(0.00, Cast(ArraySize(this.m_scrollingText.textArray))));
          s = this.m_scrollingText.textArray[j];
        };
      };
    };
    this.m_logArray[this.m_numOfLines] = s;
    sOut = "Port Probe V42.6A.9V.6B\\n";
    i = 0;
    while i < ArraySize(this.m_logArray) {
      sOut = sOut + this.m_logArray[i];
      i += 1;
    };
    inkTextRef.SetText(this.m_scannerDetailsHackLog, sOut);
    this.m_lineCount += 1;
  }

  protected cb func OnEndLoop(proxy: ref<inkAnimProxy>) -> Bool {
    this.m_upload_counter += 1.00;
    this.AddToHackLog(RoundF(this.m_upload_counter));
  }
}
