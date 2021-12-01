
public class InteractionChoiceCaptionQuickhackCostPart extends InteractionChoiceCaptionScriptPart {

  public let cost: Int32;

  protected final const func GetPartType() -> gamedataChoiceCaptionPartType {
    return gamedataChoiceCaptionPartType.QuickhackCost;
  }
}
