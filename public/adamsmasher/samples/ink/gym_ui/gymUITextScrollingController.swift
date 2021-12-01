
public class sampleTextScrolling extends inkLogicController {

  public edit let scrollingText: inkTextRef;

  private let infiniteloop: inkAnimOptions;

  protected cb func OnInitialize() -> Bool {
    this.infiniteloop.loopType = inkanimLoopType.Cycle;
    this.infiniteloop.loopInfinite = true;
    this.PlayLibraryAnimation(n"scrolltext", this.infiniteloop);
  }
}
