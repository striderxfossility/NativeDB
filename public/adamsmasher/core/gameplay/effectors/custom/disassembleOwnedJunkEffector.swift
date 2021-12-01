
public class DisassembleOwnedJunkEffector extends Effector {

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let i: Int32;
    let list: array<wref<gameItemData>>;
    GameInstance.GetTransactionSystem(owner.GetGame()).GetItemListByTag(owner, n"Junk", list);
    i = 0;
    while i < ArraySize(list) {
      ItemActionsHelper.DisassembleItem(owner, list[i].GetID(), list[i].GetQuantity());
      i += 1;
    };
  }
}
