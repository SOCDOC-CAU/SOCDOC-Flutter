class HospitalItem {
  const HospitalItem({required this.ko, required this.en, required this.id, required this.num});

  final String en;
  final String ko;
  final String id;
  final int num;
}

const List<HospitalItem> HospitalTypes = [
  HospitalItem(ko: "전체", en: "All", id: "D000", num:0),
  HospitalItem(ko: "내과", en: "Internal Medicine", id: "D001", num:1),
  HospitalItem(ko: "소아청소년과", en: "Pediatrics", id: "D002", num:2),
  HospitalItem(ko: "신경과", en: "Neurology", id: "D003", num:3),
  HospitalItem(ko: "정신건강의학과", en: "Psychiatry", id: "D004", num:4),
  HospitalItem(ko: "피부과", en: "Dermatology", id: "D005", num:5),
  HospitalItem(ko: "외과", en: "Surgical", id: "D006", num:6),
  HospitalItem(ko: "흉부외과", en: "Thoracic Surgery", id: "D007", num:7),
  HospitalItem(ko: "정형외과", en: "Orthopedics", id: "D008", num:8),
  HospitalItem(ko: "신경외과", en: "Neurosurgery", id: "D009", num:9),
  HospitalItem(ko: "성형외과", en: "Plastic Surgery", id: "D010", num:10),
  HospitalItem(ko: "산부인과", en: "Obstetrics and Gynecology", id: "D011", num:11),
  HospitalItem(ko: "안과", en: "Ophthalmology", id: "D012", num:12),
  HospitalItem(ko: "이비인후과", en: "Otolaryngology", id: "D013", num:13),
  HospitalItem(ko: "비뇨기과", en: "Urology", id: "D014", num:14),
  HospitalItem(ko: "", en: "", id: "D00", num:-1),
  HospitalItem(ko: "재활의학과", en: "Rehabilitation Medicine", id: "D016", num:16),
  HospitalItem(ko: "마취통증의학과", en: "Anesthesiology and Pain Medicine", id: "D017", num:17),
  HospitalItem(ko: "영상의학과", en: "Radiology", id: "D018", num:18),
  HospitalItem(ko: "", en: "", id: "D00", num:-1),
  HospitalItem(ko: "", en: "", id: "D00", num:-1),
  HospitalItem(ko: "", en: "", id: "D00", num:-1),
  HospitalItem(ko: "가정의학과", en: "Family Medicine", id: "D022", num:22),
  HospitalItem(ko: "", en: "", id: "D00", num:-1),
  HospitalItem(ko: "", en: "", id: "D00", num:-1),
  HospitalItem(ko: "", en: "", id: "D00", num:-1),
  HospitalItem(ko: "치과", en: "Dental", id: "D026", num:26),
  HospitalItem(ko: "", en: "", id: "D00", num:-1),
  HospitalItem(ko: "", en: "", id: "D00", num:-1),
  HospitalItem(ko: "", en: "", id: "D00", num:-1),
  HospitalItem(ko: "", en: "", id: "D00", num:-1),
  HospitalItem(ko: "", en: "", id: "D00", num:-1),
  HospitalItem(ko: "", en: "", id: "D00", num:-1),
  HospitalItem(ko: "", en: "", id: "D00", num:-1),
  HospitalItem(ko: "구강악안면외과", en: "Oral Maxillofacial Surgery", id: "D034", num:34),
];
