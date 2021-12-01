
public class LevelBarsController extends inkLogicController {

  protected edit let m_bar0: inkWidgetRef;

  protected edit let m_bar1: inkWidgetRef;

  protected edit let m_bar2: inkWidgetRef;

  protected edit let m_bar3: inkWidgetRef;

  protected edit let m_bar4: inkWidgetRef;

  protected let m_bars: array<inkWidgetRef; 5>;

  protected cb func OnInitialize() -> Bool {
    this.m_bars[0] = this.m_bar0;
    this.m_bars[1] = this.m_bar1;
    this.m_bars[2] = this.m_bar2;
    this.m_bars[3] = this.m_bar3;
    this.m_bars[4] = this.m_bar4;
  }

  public final func Update(quality: CName, opt qualityToCompare: CName) -> Void {
    if IsNameValid(qualityToCompare) {
      this.Update(UIItemsHelper.QualityNameToInt(quality), UIItemsHelper.QualityNameToInt(qualityToCompare));
    } else {
      this.Update(UIItemsHelper.QualityNameToInt(quality));
    };
  }

  public final func Update(quality: Int32) -> Void {
    this.Update(quality, -1);
  }

  public final func GetBarWidget(index: Int32) -> inkWidgetRef {
    if index < ArraySize(this.m_bars) {
      return this.m_bars[index];
    };
    return this.m_bars[4];
  }

  public final func Update(quality: Int32, qualityToCompare: Int32) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_bars) {
      if i <= quality {
        inkWidgetRef.SetState(this.m_bars[i], UIItemsHelper.QualityIntToName(quality));
      } else {
        inkWidgetRef.SetState(this.m_bars[i], n"Empty");
      };
      if qualityToCompare > -1 {
        if quality > qualityToCompare {
          if i > qualityToCompare && i <= quality {
            inkWidgetRef.SetState(this.m_bars[i], n"Better");
          };
        };
        if quality < qualityToCompare {
          if i > quality && i <= qualityToCompare {
            inkWidgetRef.SetState(this.m_bars[i], n"Worse");
          };
        };
      };
      i += 1;
    };
  }
}
