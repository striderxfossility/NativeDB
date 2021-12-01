
public abstract class ScriptConditionTypeBase extends IScriptable {

  public const quest func Evaluate(playerObject: ref<GameObject>) -> Bool {
    return false;
  }

  public const quest func ToString() -> String {
    return "";
  }
}

public abstract class BluelineConditionTypeBase extends ScriptConditionTypeBase {

  public const func GetBluelinePart(playerObject: ref<GameObject>) -> ref<BluelinePart> {
    let part: ref<BluelinePart>;
    return part;
  }

  public func ExecuteBluelineAction(playerObject: ref<GameObject>) -> Void;
}

public class LifePath_ScriptConditionType extends BluelineConditionTypeBase {

  @attrib(customEditor, "TweakDBGroupInheritance;LifePath")
  public let m_lifePathId: TweakDBID;

  public let m_inverted: Bool;

  public const quest func Evaluate(playerObject: ref<GameObject>) -> Bool {
    let playerControlledObject: ref<GameObject>;
    let playerDevSystem: ref<PlayerDevelopmentSystem> = this.GetPlayerDevelopmentSystem();
    let playerLifePath: gamedataLifePath = playerDevSystem.GetLifePath(playerObject);
    let lifePath: gamedataLifePath = TweakDBInterface.GetLifePathRecord(this.m_lifePathId).Type();
    if !IsDefined(playerObject) {
      return false;
    };
    playerControlledObject = GameInstance.GetPlayerSystem(playerObject.GetGame()).GetLocalPlayerControlledGameObject();
    playerLifePath = playerDevSystem.GetLifePath(playerControlledObject);
    if !this.m_inverted {
      return Equals(lifePath, playerLifePath);
    };
    return NotEquals(lifePath, playerLifePath);
  }

  public const func GetBluelinePart(playerObject: ref<GameObject>) -> ref<BluelinePart> {
    let part: ref<LifePathBluelinePart> = new LifePathBluelinePart();
    part.passed = this.Evaluate(playerObject);
    part.m_record = TweakDBInterface.GetLifePathRecord(this.m_lifePathId);
    part.captionIconRecordId = part.m_record.CaptionIcon().GetID();
    return part;
  }

  public const quest func ToString() -> String {
    let outString: String;
    if this.m_inverted {
      outString += "NOT ";
    };
    outString += TDBID.ToStringDEBUG(this.m_lifePathId);
    return outString;
  }

  private final const func GetPlayerDevelopmentSystem() -> ref<PlayerDevelopmentSystem> {
    return GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"PlayerDevelopmentSystem") as PlayerDevelopmentSystem;
  }
}

public class Build_ScriptConditionType extends BluelineConditionTypeBase {

  @attrib(customEditor, "TweakDBGroupInheritance;ContentAssignment")
  public let m_questAssignment: TweakDBID;

  @attrib(customEditor, "TweakDBGroupInheritance;PlayerBuild")
  public let m_buildId: TweakDBID;

  public let m_difficulty: EGameplayChallengeLevel;

  public let m_comparisonType: ECompareOp;

  public const quest func Evaluate(playerObject: ref<GameObject>) -> Bool {
    let playerValue: Int32 = RPGManager.GetBuildScore(playerObject, TweakDBInterface.GetPlayerBuildRecord(this.m_buildId));
    let checkValue: Int32 = RPGManager.GetBluelineBuildCheckValue(playerObject, TweakDBInterface.GetContentAssignmentRecord(this.m_questAssignment), this.m_difficulty);
    switch this.m_comparisonType {
      case ECompareOp.CO_Lesser:
        return playerValue < checkValue;
      case ECompareOp.CO_LesserEq:
        return playerValue <= checkValue;
      case ECompareOp.CO_Greater:
        return playerValue > checkValue;
      case ECompareOp.CO_GreaterEq:
        return playerValue >= checkValue;
      case ECompareOp.CO_Equal:
        return playerValue == checkValue;
      case ECompareOp.CO_NotEqual:
        return playerValue != checkValue;
    };
  }

  public const func GetBluelinePart(playerObject: ref<GameObject>) -> ref<BluelinePart> {
    let part: ref<BuildBluelinePart> = new BuildBluelinePart();
    part.m_lhsValue = RPGManager.GetBuildScore(playerObject, TweakDBInterface.GetPlayerBuildRecord(this.m_buildId));
    part.m_rhsValue = RPGManager.GetBluelineBuildCheckValue(playerObject, TweakDBInterface.GetContentAssignmentRecord(this.m_questAssignment), this.m_difficulty);
    part.passed = this.Evaluate(playerObject);
    part.m_record = TweakDBInterface.GetPlayerBuildRecord(this.m_buildId);
    part.m_comparisonOperator = this.m_comparisonType;
    part.captionIconRecordId = part.m_record.CaptionIcon().GetID();
    return part;
  }

  public const quest func ToString() -> String {
    let outString: String = TDBID.ToStringDEBUG(this.m_buildId) + " " + ToString(this.m_comparisonType) + " " + ToString(this.m_difficulty);
    return outString;
  }
}

public class PaymentConditionTypeBase extends BluelineConditionTypeBase {

  public let m_inverted: Bool;

  @default(PaymentConditionTypeBase, true)
  public let m_payWhenSucceded: Bool;

  public final const quest func IsInverted() -> Bool {
    return this.m_inverted;
  }

  public final const quest func IsPaidWhenSucceeded() -> Bool {
    return this.m_payWhenSucceded;
  }

  public const quest func GetPaymentAmount(playerObject: ref<GameObject>) -> Uint32 {
    return 0u;
  }

  public final const quest func GetPaymentMoneyItemId() -> ItemID {
    return MarketSystem.Money();
  }

  public final const quest func Evaluate(playerObject: ref<GameObject>) -> Bool {
    let playerMoney: Int32 = GameInstance.GetTransactionSystem(playerObject.GetGame()).GetItemQuantity(playerObject, this.GetPaymentMoneyItemId());
    let paymentMoney: Int32 = Cast(this.GetPaymentAmount(playerObject));
    return this.m_inverted ? playerMoney < paymentMoney : playerMoney >= paymentMoney;
  }

  public func ExecuteBluelineAction(playerObject: ref<GameObject>) -> Void {
    let paymentAmount: Int32;
    if !this.IsInverted() {
      if this.IsPaidWhenSucceeded() {
        paymentAmount = Cast(this.GetPaymentAmount(playerObject));
        GameInstance.GetTransactionSystem(GetGameInstance()).RemoveItem(playerObject, this.GetPaymentMoneyItemId(), paymentAmount);
      };
    };
  }

  protected final func GetPaymentData(playerObject: ref<GameObject>) -> questPaymentConditionData {
    let ret: questPaymentConditionData;
    ret.isInverted = this.m_inverted;
    ret.paymentItemId = this.GetPaymentMoneyItemId();
    ret.paymentAmount = this.GetPaymentAmount(playerObject);
    return ret;
  }
}

public class PaymentBalanced_ScriptConditionType extends PaymentConditionTypeBase {

  @attrib(customEditor, "TweakDBGroupInheritance;ContentAssignment")
  public let m_questAssignment: TweakDBID;

  public let m_difficulty: EGameplayChallengeLevel;

  public const quest func GetPaymentAmount(playerObject: ref<GameObject>) -> Uint32 {
    return Cast(RPGManager.GetBluelinePaymentValue(playerObject, TweakDBInterface.GetContentAssignmentRecord(this.m_questAssignment), this.m_difficulty));
  }

  public const func GetBluelinePart(playerObject: ref<GameObject>) -> ref<BluelinePart> {
    let part: ref<PaymentBluelinePart> = new PaymentBluelinePart();
    part.m_playerMoney = GameInstance.GetTransactionSystem(playerObject.GetGame()).GetItemQuantity(playerObject, this.GetPaymentMoneyItemId());
    part.m_paymentMoney = RPGManager.GetBluelinePaymentValue(playerObject, TweakDBInterface.GetContentAssignmentRecord(this.m_questAssignment), this.m_difficulty);
    part.passed = this.Evaluate(playerObject);
    part.captionIconRecordId = t"ChoiceCaptionParts.OpenVendorIcon";
    return part;
  }

  public const quest func ToString() -> String {
    let outString: String = ToString(this.m_difficulty);
    return outString;
  }
}

public class PaymentFixedAmount_ScriptConditionType extends PaymentConditionTypeBase {

  public let m_payAmount: Uint32;

  public final quest func SetPayAmountValue(value: Uint32) -> Void {
    this.m_payAmount = value;
  }

  public const quest func GetPaymentAmount(playerObject: ref<GameObject>) -> Uint32 {
    return this.m_payAmount;
  }

  public const func GetBluelinePart(playerObject: ref<GameObject>) -> ref<BluelinePart> {
    let part: ref<PaymentBluelinePart> = new PaymentBluelinePart();
    part.m_playerMoney = GameInstance.GetTransactionSystem(playerObject.GetGame()).GetItemQuantity(playerObject, MarketSystem.Money());
    part.m_paymentMoney = Cast(this.m_payAmount);
    part.passed = this.Evaluate(playerObject);
    part.captionIconRecordId = t"ChoiceCaptionParts.OpenVendorIcon";
    return part;
  }

  public const quest func ToString() -> String {
    let outString: String = IntToString(Cast(this.m_payAmount));
    return outString;
  }
}
