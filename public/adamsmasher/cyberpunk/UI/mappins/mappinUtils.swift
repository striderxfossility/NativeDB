
public native struct MappinUIUtils {

  public final static native func GetEngineTime() -> EngineTime;

  public final static native func GetGlobalProfile() -> ref<MappinUIGlobalProfile_Record>;

  public final static native func GetDistrictRecord(districtType: gamedataDistrict) -> wref<District_Record>;

  private final static native func GetFilterGroupFromFilter(filter: gamedataWorldMapFilter) -> wref<MappinUIFilterGroup_Record>;

  private final static native func GetFilterGroupFromVariant(mappinVariant: gamedataMappinVariant) -> wref<MappinUIFilterGroup_Record>;

  public final static func GetFilterGroup(filter: gamedataWorldMapFilter) -> wref<MappinUIFilterGroup_Record> {
    return MappinUIUtils.GetFilterGroupFromFilter(filter);
  }

  public final static func GetFilterGroup(mappinVariant: gamedataMappinVariant) -> wref<MappinUIFilterGroup_Record> {
    return MappinUIUtils.GetFilterGroupFromVariant(mappinVariant);
  }

  public final static native func IsPlayerInArea(mappin: wref<IMappin>) -> Bool;

  public final static func IsMappinServicePoint(mappinVariant: gamedataMappinVariant) -> Bool {
    switch mappinVariant {
      case gamedataMappinVariant.ServicePointDropPointVariant:
      case gamedataMappinVariant.ServicePointJunkVariant:
      case gamedataMappinVariant.ServicePointTechVariant:
      case gamedataMappinVariant.ServicePointRipperdocVariant:
      case gamedataMappinVariant.ServicePointProstituteVariant:
      case gamedataMappinVariant.ServicePointNetTrainerVariant:
      case gamedataMappinVariant.ServicePointMeleeTrainerVariant:
      case gamedataMappinVariant.ServicePointMedsVariant:
      case gamedataMappinVariant.ServicePointGunsVariant:
      case gamedataMappinVariant.ServicePointBarVariant:
      case gamedataMappinVariant.ServicePointFoodVariant:
      case gamedataMappinVariant.ServicePointClothesVariant:
        return true;
    };
    return false;
  }

  public final static func MappinToTexturePart(mappin: wref<IMappin>) -> CName {
    return MappinUIUtils.MappinToTexturePart(mappin.GetVariant(), mappin.GetPhase());
  }

  public final static func MappinToTexturePart(mappinVariant: gamedataMappinVariant, mappinPhase: gamedataMappinPhase) -> CName {
    if Equals(mappinPhase, gamedataMappinPhase.UndiscoveredPhase) {
      return n"undiscovered";
    };
    return MappinUIUtils.MappinToTexturePart(mappinVariant);
  }

  public final static func MappinToTexturePart(mappinVariant: gamedataMappinVariant) -> CName {
    switch mappinVariant {
      case gamedataMappinVariant.DefaultVariant:
        return n"quest";
      case gamedataMappinVariant.DefaultQuestVariant:
        return n"minor_quest";
      case gamedataMappinVariant.DefaultInteractionVariant:
        return n"quest";
      case gamedataMappinVariant.ConversationVariant:
        return n"talk";
      case gamedataMappinVariant.QuestGiverVariant:
        return n"quest_giver";
      case gamedataMappinVariant.MinorActivityVariant:
        return n"minor_activity";
      case gamedataMappinVariant.ExclamationMarkVariant:
        return n"quest";
      case gamedataMappinVariant.RetrievingVariant:
        return n"retrieving";
      case gamedataMappinVariant.ThieveryVariant:
        return n"thievery";
      case gamedataMappinVariant.SabotageVariant:
        return n"sabotage";
      case gamedataMappinVariant.ClientInDistressVariant:
        return n"client_in_distress";
      case gamedataMappinVariant.BountyHuntVariant:
        return n"bounty_hunt";
      case gamedataMappinVariant.CourierVariant:
        return n"courier";
      case gamedataMappinVariant.GangWatchVariant:
        return n"gang_watch";
      case gamedataMappinVariant.OutpostVariant:
        return n"outpost";
      case gamedataMappinVariant.ResourceVariant:
        return n"resource";
      case gamedataMappinVariant.HiddenStashVariant:
        return n"hidden_stash";
      case gamedataMappinVariant.HuntForPsychoVariant:
        return n"hunt_for_psycho";
      case gamedataMappinVariant.SmugglersDenVariant:
        return n"smugglers";
      case gamedataMappinVariant.WanderingMerchantVariant:
        return n"wandering_merchant";
      case gamedataMappinVariant.ConvoyVariant:
        return n"convoy";
      case gamedataMappinVariant.FixerVariant:
        return n"fixer";
      case gamedataMappinVariant.DropboxVariant:
        return n"dropbox";
      case gamedataMappinVariant.ApartmentVariant:
        return n"apartment";
      case gamedataMappinVariant.ServicePointClothesVariant:
        return n"clothes";
      case gamedataMappinVariant.ServicePointFoodVariant:
        return n"food_vendor";
      case gamedataMappinVariant.ServicePointBarVariant:
        return n"bar";
      case gamedataMappinVariant.ServicePointGunsVariant:
        return n"gun";
      case gamedataMappinVariant.ServicePointMedsVariant:
        return n"medicine";
      case gamedataMappinVariant.ServicePointMeleeTrainerVariant:
        return n"melee";
      case gamedataMappinVariant.ServicePointNetTrainerVariant:
        return n"netservice";
      case gamedataMappinVariant.ServicePointProstituteVariant:
        return n"prostitute";
      case gamedataMappinVariant.ServicePointRipperdocVariant:
        return n"ripperdoc";
      case gamedataMappinVariant.ServicePointTechVariant:
        return n"tech";
      case gamedataMappinVariant.ServicePointJunkVariant:
        return n"junk_shop";
      case gamedataMappinVariant.FastTravelVariant:
        return n"fast_travel";
      case gamedataMappinVariant.EffectDropPointVariant:
        return n"dropbox";
      case gamedataMappinVariant.ServicePointDropPointVariant:
        return n"dropbox";
      case gamedataMappinVariant.VehicleVariant:
        return n"car";
      case gamedataMappinVariant.Zzz03_MotorcycleVariant:
        return n"motorcycle";
      case gamedataMappinVariant.Zzz01_CarForPurchaseVariant:
        return n"car_to_buy";
      case gamedataMappinVariant.Zzz02_MotorcycleForPurchaseVariant:
        return n"motorcycle_to_buy";
      case gamedataMappinVariant.GrenadeVariant:
        return n"grenade";
      case gamedataMappinVariant.CustomPositionVariant:
        return n"dynamic_event";
      case gamedataMappinVariant.InvalidVariant:
        return n"invalid";
      case gamedataMappinVariant.SitVariant:
        return n"Sit";
      case gamedataMappinVariant.GetInVariant:
        return n"GetIn";
      case gamedataMappinVariant.GetUpVariant:
        return n"GetUp";
      case gamedataMappinVariant.AllowVariant:
        return n"Allow";
      case gamedataMappinVariant.BackOutVariant:
        return n"BackOut";
      case gamedataMappinVariant.JackInVariant:
        return n"JackIn";
      case gamedataMappinVariant.HitVariant:
        return n"Hit";
      case gamedataMappinVariant.TakeDownVariant:
        return n"TakeDown";
      case gamedataMappinVariant.NonLethalTakedownVariant:
        return n"NonLethalTakedown";
      case gamedataMappinVariant.TakeControlVariant:
        return n"TakeControl";
      case gamedataMappinVariant.OpenVendorVariant:
        return n"OpenVendor";
      case gamedataMappinVariant.DistractVariant:
        return n"Distract";
      case gamedataMappinVariant.ChangeToFriendlyVariant:
        return n"ChangeToFriendly";
      case gamedataMappinVariant.GunSuicideVariant:
        return n"GunSuicide";
      case gamedataMappinVariant.LifepathCorpoVariant:
        return n"LifepathCorpo";
      case gamedataMappinVariant.LifepathNomadVariant:
        return n"LifepathNomad";
      case gamedataMappinVariant.LifepathStreetKidVariant:
        return n"LifepathStreetKid";
      case gamedataMappinVariant.AimVariant:
        return n"Aim";
      case gamedataMappinVariant.JamWeaponVariant:
        return n"JamWeapon";
      case gamedataMappinVariant.OffVariant:
        return n"Off";
      case gamedataMappinVariant.UseVariant:
        return n"Use";
      case gamedataMappinVariant.PhoneCallVariant:
        return n"PhoneCall";
      case gamedataMappinVariant.SpeechVariant:
        return n"talk";
      case gamedataMappinVariant.GPSPortalVariant:
        return n"quest";
      case gamedataMappinVariant.FailedCrossingVariant:
        return n"failed_crossing";
      case gamedataMappinVariant.TarotVariant:
        return n"tarot_card";
      default:
        return n"invalid";
    };
  }

  public final static func MappinToString(mappinVariant: gamedataMappinVariant, mappinPhase: gamedataMappinPhase) -> CName {
    if Equals(mappinPhase, gamedataMappinPhase.UndiscoveredPhase) {
      return n"UI-MappinTypes-Undiscovered";
    };
    return MappinUIUtils.MappinToString(mappinVariant);
  }

  public final static func MappinToString(mappinVariant: gamedataMappinVariant) -> CName {
    switch mappinVariant {
      case gamedataMappinVariant.DefaultQuestVariant:
        return n"UI-MappinTypes-MinorQuest";
      case gamedataMappinVariant.ConversationVariant:
        return n"UI-MappinTypes-Conversation";
      case gamedataMappinVariant.QuestGiverVariant:
        return n"UI-MappinTypes-QuestGiver";
      case gamedataMappinVariant.MinorActivityVariant:
        return n"UI-MappinTypes-MinorActivity";
      case gamedataMappinVariant.ExclamationMarkVariant:
        return n"UI-MappinTypes-Quest";
      case gamedataMappinVariant.RetrievingVariant:
        return n"UI-MappinTypes-Retrieving";
      case gamedataMappinVariant.ThieveryVariant:
        return n"UI-MappinTypes-Thievery";
      case gamedataMappinVariant.SabotageVariant:
        return n"UI-MappinTypes-Sabotage";
      case gamedataMappinVariant.ClientInDistressVariant:
        return n"UI-MappinTypes-ClientinDistress";
      case gamedataMappinVariant.BountyHuntVariant:
        return n"UI-MappinTypes-BountyHunt";
      case gamedataMappinVariant.CourierVariant:
        return n"UI-MappinTypes-Courier";
      case gamedataMappinVariant.GangWatchVariant:
        return n"UI-MappinTypes-GangWatch";
      case gamedataMappinVariant.OutpostVariant:
        return n"UI-MappinTypes-Outpost";
      case gamedataMappinVariant.ResourceVariant:
        return n"UI-MappinTypes-Resource";
      case gamedataMappinVariant.HiddenStashVariant:
        return n"UI-MappinTypes-HiddenStash";
      case gamedataMappinVariant.HuntForPsychoVariant:
        return n"UI-MappinTypes-HuntforPsycho";
      case gamedataMappinVariant.SmugglersDenVariant:
        return n"UI-MappinTypes-SmugglersDen";
      case gamedataMappinVariant.WanderingMerchantVariant:
        return n"UI-MappinTypes-WanderingMerchant";
      case gamedataMappinVariant.ConvoyVariant:
        return n"UI-MappinTypes-Convoy";
      case gamedataMappinVariant.FixerVariant:
        return n"UI-MappinTypes-Fixer";
      case gamedataMappinVariant.DropboxVariant:
        return n"UI-MappinTypes-Dropbox";
      case gamedataMappinVariant.ApartmentVariant:
        return n"UI-MappinTypes-Apartment";
      case gamedataMappinVariant.ServicePointClothesVariant:
        return n"UI-MappinTypes-ClothingServicePoint";
      case gamedataMappinVariant.ServicePointFoodVariant:
        return n"UI-MappinTypes-FoodServicePoint";
      case gamedataMappinVariant.ServicePointBarVariant:
        return n"UI-MappinTypes-BarServicePoint";
      case gamedataMappinVariant.ServicePointGunsVariant:
        return n"UI-MappinTypes-GunServicePoint";
      case gamedataMappinVariant.ServicePointMedsVariant:
        return n"UI-MappinTypes-MedicineServicePoint";
      case gamedataMappinVariant.ServicePointMeleeTrainerVariant:
        return n"UI-MappinTypes-MeleeServicePoint";
      case gamedataMappinVariant.ServicePointNetTrainerVariant:
        return n"UI-MappinTypes-NetTrainerServicePoint";
      case gamedataMappinVariant.ServicePointProstituteVariant:
        return n"UI-MappinTypes-Prostitute";
      case gamedataMappinVariant.ServicePointRipperdocVariant:
        return n"UI-MappinTypes-RipperdocServicePoint";
      case gamedataMappinVariant.ServicePointTechVariant:
        return n"UI-MappinTypes-TechServicePoint";
      case gamedataMappinVariant.ServicePointJunkVariant:
        return n"UI-MappinTypes-JunkServicePoint";
      case gamedataMappinVariant.FastTravelVariant:
        return n"UI-MappinTypes-FastTravel";
      case gamedataMappinVariant.EffectDropPointVariant:
        return n"UI-MappinTypes-Dropbox";
      case gamedataMappinVariant.ServicePointDropPointVariant:
        return n"UI-MappinTypes-Dropbox";
      case gamedataMappinVariant.VehicleVariant:
        return n"UI-MappinTypes-Vehicle";
      case gamedataMappinVariant.Zzz03_MotorcycleVariant:
        return n"UI-MappinTypes-Vehicle";
      case gamedataMappinVariant.Zzz01_CarForPurchaseVariant:
        return n"UI-MappinTypes-CarForPurchase";
      case gamedataMappinVariant.Zzz02_MotorcycleForPurchaseVariant:
        return n"UI-MappinTypes-MotorcycleForPurchase";
      case gamedataMappinVariant.CustomPositionVariant:
        return n"UI-MappinTypes-CustomLocation";
      case gamedataMappinVariant.InvalidVariant:
        return n"UI-MappinTypes-Invalid";
      case gamedataMappinVariant.SitVariant:
        return n"UI-MappinTypes-Sit";
      case gamedataMappinVariant.GetInVariant:
        return n"UI-MappinTypes-GetIn";
      case gamedataMappinVariant.GetUpVariant:
        return n"UI-MappinTypes-GetUp";
      case gamedataMappinVariant.AllowVariant:
        return n"UI-MappinTypes-Allow";
      case gamedataMappinVariant.BackOutVariant:
        return n"UI-MappinTypes-BackOut";
      case gamedataMappinVariant.JackInVariant:
        return n"UI-MappinTypes-JackIn";
      case gamedataMappinVariant.HitVariant:
        return n"UI-MappinTypes-Hit";
      case gamedataMappinVariant.TakeDownVariant:
        return n"UI-MappinTypes-TakeDown";
      case gamedataMappinVariant.NonLethalTakedownVariant:
        return n"NonLethalTakedown";
      case gamedataMappinVariant.TakeControlVariant:
        return n"TakeControl";
      case gamedataMappinVariant.OpenVendorVariant:
        return n"UI-MappinTypes-OpenVendor";
      case gamedataMappinVariant.DistractVariant:
        return n"UI-MappinTypes-Distract";
      case gamedataMappinVariant.ChangeToFriendlyVariant:
        return n"UI-MappinTypes-ChangeToFriendly";
      case gamedataMappinVariant.GunSuicideVariant:
        return n"UI-MappinTypes-GunSuicide";
      case gamedataMappinVariant.LifepathCorpoVariant:
        return n"UI-MappinTypes-LifepathCorpo";
      case gamedataMappinVariant.LifepathNomadVariant:
        return n"UI-MappinTypes-LifepathNomad";
      case gamedataMappinVariant.LifepathStreetKidVariant:
        return n"UI-MappinTypes-LifepathStreetKid";
      case gamedataMappinVariant.AimVariant:
        return n"UI-MappinTypes-Aim";
      case gamedataMappinVariant.JamWeaponVariant:
        return n"UI-MappinTypes-JamWeapon";
      case gamedataMappinVariant.OffVariant:
        return n"UI-MappinTypes-Off";
      case gamedataMappinVariant.UseVariant:
        return n"UI-MappinTypes-Use";
      case gamedataMappinVariant.PhoneCallVariant:
        return n"UI-MappinTypes-PhoneCall";
      case gamedataMappinVariant.FailedCrossingVariant:
        return n"UI-MappinTypes-FailedCrossing";
      case gamedataMappinVariant.TarotVariant:
        return n"UI-MappinTypes-Tarot";
    };
    return n"UI-MappinTypes-UNKNOWN";
  }

  public final static func MappinToDescriptionString(mappinVariant: gamedataMappinVariant) -> CName {
    switch mappinVariant {
      case gamedataMappinVariant.DefaultQuestVariant:
        return n"UI-MappinTypes-MinorQuestDescription";
      case gamedataMappinVariant.ConversationVariant:
        return n"UI-MappinTypes-ConversationDescription";
      case gamedataMappinVariant.QuestGiverVariant:
        return n"UI-MappinTypes-QuestGiverDescription";
      case gamedataMappinVariant.MinorActivityVariant:
        return n"UI-MappinTypes-MinorActivityDescription";
      case gamedataMappinVariant.ExclamationMarkVariant:
        return n"UI-MappinTypes-QuestDescription";
      case gamedataMappinVariant.RetrievingVariant:
        return n"UI-MappinTypes-RetrievingDescription";
      case gamedataMappinVariant.ThieveryVariant:
        return n"UI-MappinTypes-ThieveryDescription";
      case gamedataMappinVariant.SabotageVariant:
        return n"UI-MappinTypes-SabotageDescription";
      case gamedataMappinVariant.ClientInDistressVariant:
        return n"UI-MappinTypes-ClientinDistressDescription";
      case gamedataMappinVariant.BountyHuntVariant:
        return n"UI-MappinTypes-BountyHuntDescription";
      case gamedataMappinVariant.CourierVariant:
        return n"UI-MappinTypes-CourierDescription";
      case gamedataMappinVariant.GangWatchVariant:
        return n"UI-MappinTypes-GangWatchDescription";
      case gamedataMappinVariant.OutpostVariant:
        return n"UI-MappinTypes-OutpostDescription";
      case gamedataMappinVariant.ResourceVariant:
        return n"UI-MappinTypes-ResourceDescription";
      case gamedataMappinVariant.HiddenStashVariant:
        return n"UI-MappinTypes-HiddenStashDescription";
      case gamedataMappinVariant.HuntForPsychoVariant:
        return n"UI-MappinTypes-HuntforPsychoDescription";
      case gamedataMappinVariant.SmugglersDenVariant:
        return n"UI-MappinTypes-SmugglersDenDescription";
      case gamedataMappinVariant.WanderingMerchantVariant:
        return n"UI-MappinTypes-WanderingMerchantDescription";
      case gamedataMappinVariant.ConvoyVariant:
        return n"UI-MappinTypes-ConvoyDescription";
      case gamedataMappinVariant.FixerVariant:
        return n"UI-MappinTypes-FixerDescription";
      case gamedataMappinVariant.DropboxVariant:
        return n"UI-MappinTypes-DropboxDescription";
      case gamedataMappinVariant.ApartmentVariant:
        return n"UI-MappinTypes-ApartmentDescription";
      case gamedataMappinVariant.ServicePointClothesVariant:
        return n"UI-MappinTypes-ClothingServicePointDescription";
      case gamedataMappinVariant.ServicePointFoodVariant:
        return n"UI-MappinTypes-FoodServicePointDescription";
      case gamedataMappinVariant.ServicePointBarVariant:
        return n"UI-MappinTypes-BarServicePointDescription";
      case gamedataMappinVariant.ServicePointGunsVariant:
        return n"UI-MappinTypes-GunServicePointDescription";
      case gamedataMappinVariant.ServicePointMedsVariant:
        return n"UI-MappinTypes-MedicineServicePointDescription";
      case gamedataMappinVariant.ServicePointMeleeTrainerVariant:
        return n"UI-MappinTypes-MeleeServicePointDescription";
      case gamedataMappinVariant.ServicePointNetTrainerVariant:
        return n"UI-MappinTypes-NetTrainerServicePointDescription";
      case gamedataMappinVariant.ServicePointProstituteVariant:
        return n"UI-MappinTypes-ProstituteDescription";
      case gamedataMappinVariant.ServicePointRipperdocVariant:
        return n"UI-MappinTypes-RipperdocServicePointDescription";
      case gamedataMappinVariant.ServicePointTechVariant:
        return n"UI-MappinTypes-TechServicePointDescription";
      case gamedataMappinVariant.ServicePointJunkVariant:
        return n"UI-MappinTypes-JunkServicePointDescription";
      case gamedataMappinVariant.FastTravelVariant:
        return n"UI-MappinTypes-FastTravelDescription";
      case gamedataMappinVariant.EffectDropPointVariant:
        return n"UI-MappinTypes-DropboxDescription";
      case gamedataMappinVariant.ServicePointDropPointVariant:
        return n"UI-MappinTypes-DropboxDescription";
      case gamedataMappinVariant.VehicleVariant:
        return n"UI-MappinTypes-VehicleDescription";
      case gamedataMappinVariant.Zzz03_MotorcycleVariant:
        return n"UI-MappinTypes-VehicleDescription";
      case gamedataMappinVariant.Zzz01_CarForPurchaseVariant:
        return n"UI-MappinTypes-CarForPurchaseDescription";
      case gamedataMappinVariant.Zzz02_MotorcycleForPurchaseVariant:
        return n"UI-MappinTypes-MotorcycleForPurchaseDescription";
      case gamedataMappinVariant.CustomPositionVariant:
        return n"UI-MappinTypes-CustomLocationDescription";
      case gamedataMappinVariant.InvalidVariant:
        return n"UI-MappinTypes-Invalid-Description";
      case gamedataMappinVariant.SitVariant:
        return n"UI-MappinTypes-Sit-Description";
      case gamedataMappinVariant.GetInVariant:
        return n"UI-MappinTypes-GetIn-Description";
      case gamedataMappinVariant.GetUpVariant:
        return n"UI-MappinTypes-GetUp-Description";
      case gamedataMappinVariant.AllowVariant:
        return n"UI-MappinTypes-Allow-Description";
      case gamedataMappinVariant.BackOutVariant:
        return n"UI-MappinTypes-BackOut-Description";
      case gamedataMappinVariant.JackInVariant:
        return n"UI-MappinTypes-JackIn-Description";
      case gamedataMappinVariant.HitVariant:
        return n"UI-MappinTypes-Hit-Description";
      case gamedataMappinVariant.TakeDownVariant:
        return n"UI-MappinTypes-TakeDown-Description";
      case gamedataMappinVariant.NonLethalTakedownVariant:
        return n"NonLethalTakedown-Description";
      case gamedataMappinVariant.TakeControlVariant:
        return n"TakeControl-Description";
      case gamedataMappinVariant.OpenVendorVariant:
        return n"UI-MappinTypes-OpenVendor-Description";
      case gamedataMappinVariant.DistractVariant:
        return n"UI-MappinTypes-Distract-Description";
      case gamedataMappinVariant.ChangeToFriendlyVariant:
        return n"UI-MappinTypes-ChangeToFriendly-Description";
      case gamedataMappinVariant.GunSuicideVariant:
        return n"UI-MappinTypes-GunSuicide-Description";
      case gamedataMappinVariant.LifepathCorpoVariant:
        return n"UI-MappinTypes-LifepathCorpo-Description";
      case gamedataMappinVariant.LifepathNomadVariant:
        return n"UI-MappinTypes-LifepathNomad-Description";
      case gamedataMappinVariant.LifepathStreetKidVariant:
        return n"UI-MappinTypes-LifepathStreetKid-Description";
      case gamedataMappinVariant.AimVariant:
        return n"UI-MappinTypes-Aim-Description";
      case gamedataMappinVariant.JamWeaponVariant:
        return n"UI-MappinTypes-JamWeapon-Description";
      case gamedataMappinVariant.OffVariant:
        return n"UI-MappinTypes-Off-Description";
      case gamedataMappinVariant.UseVariant:
        return n"UI-MappinTypes-Use-Description";
      case gamedataMappinVariant.PhoneCallVariant:
        return n"UI-MappinTypes-PhoneCall-Description";
      case gamedataMappinVariant.FailedCrossingVariant:
        return n"UI-MappinTypes-FailedCrossingDescription";
      case gamedataMappinVariant.TarotVariant:
        return n"UI-MappinTypes-TarotDescription";
    };
    return n"UI-MappinTypes-UNKNOWN";
  }

  public final static func MappinToObjectiveString(mappinVariant: gamedataMappinVariant) -> CName {
    switch mappinVariant {
      case gamedataMappinVariant.GangWatchVariant:
        return n"UI-MappinTypes-GangWatchObjective";
      case gamedataMappinVariant.OutpostVariant:
        return n"UI-MappinTypes-OutpostObjective";
      case gamedataMappinVariant.ResourceVariant:
        return n"UI-MappinTypes-ResourceObjective";
      case gamedataMappinVariant.HiddenStashVariant:
        return n"UI-MappinTypes-HiddenStashObjective";
      case gamedataMappinVariant.HuntForPsychoVariant:
        return n"UI-MappinTypes-HuntforPsychoObjective";
      case gamedataMappinVariant.SmugglersDenVariant:
        return n"UI-MappinTypes-SmugglersDenObjective";
      case gamedataMappinVariant.FailedCrossingVariant:
        return n"UI-MappinTypes-FailedCrossingObjective";
      case gamedataMappinVariant.CustomPositionVariant:
        return n"UI-MappinTypes-DynamicEventObjective";
      case gamedataMappinVariant.TarotVariant:
        return n"UI-MappinTypes-TarotObjective";
    };
    return n"UI-MappinTypes-UNKNOWN";
  }

  public final static func PlayPreventionBlinkAnimation(widget: wref<inkWidget>, out initialState: CName) -> ref<inkAnimProxy> {
    let animDef: ref<inkAnimDef>;
    let animInterp: ref<inkAnimPadding>;
    let animOptions: inkAnimOptions;
    let engineTime: Float = EngineTime.ToFloat(MappinUIUtils.GetEngineTime());
    let engineTimeInt: Int32 = Cast(engineTime);
    let timeDelay: Float = 1.00 - engineTime - Cast(engineTimeInt);
    if timeDelay > 0.50 {
      timeDelay -= 0.50;
      initialState = n"Prevention_Blue";
    } else {
      initialState = n"Prevention_Red";
    };
    animDef = new inkAnimDef();
    animInterp = new inkAnimPadding();
    animInterp.SetDuration(0.50);
    animDef.AddInterpolator(animInterp);
    animOptions.loopType = inkanimLoopType.Cycle;
    animOptions.loopInfinite = true;
    animOptions.executionDelay = timeDelay;
    return widget.PlayAnimationWithOptions(animDef, animOptions);
  }

  public final static func CyclePreventionState(out state: CName) -> Void {
    state = Equals(state, n"Prevention_Red") ? n"Prevention_Blue" : n"Prevention_Red";
  }
}
