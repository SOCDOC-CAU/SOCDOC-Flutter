import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:socdoc_flutter/Utils/AuthUtil.dart';

import 'package:socdoc_flutter/Utils/Color.dart';

class ReviewPage extends StatefulWidget {
  final Function()? onReviewUpdate;

  const ReviewPage({super.key, required this.hospitalID, required this.hospitalName, required this.onReviewUpdate});

  final String hospitalID;
  final String hospitalName;

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  XFile? inputPhoto;
  var inputRating = 0;
  var inputReviewText = "";
  var isPhotoLoaded = false;
  TextEditingController reviewTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context),
            _buildRatingSection(),
            _buildDivider(),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReviewInput(),
                  _buildPhotoButton(),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadReview() async {
    var request = http.MultipartRequest("POST", Uri.parse("https://socdoc.dev-lr.com/api/review"));
    request.fields["content"] = inputReviewText;
    request.fields["hospitalId"] = widget.hospitalID;
    request.fields["rating"] = inputRating.toString();
    request.fields["userId"] = getUserID(context);
    request.files.add(await http.MultipartFile.fromPath("files", inputPhoto!.path));
    request.send().then((res){
      if(res.statusCode == 200) {
        widget.onReviewUpdate?.call();
        Navigator.pop(context);
      }
    }).onError((error, stackTrace){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${error.toString()}")));
    });
  }

  Widget _buildAppBar(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: Center(
                  child: Text(widget.hospitalName, style: const TextStyle(fontSize: 22)),
                ),
              ),
              TextButton(
                child: const Text('완료', style: TextStyle(fontSize: 17, color: AppColor.SocdocBlue)),
                onPressed: () {
                  inputReviewText = reviewTextController.text;
                  if(inputPhoto != null && inputRating > 0 && inputReviewText.isNotEmpty){
                    _uploadReview();
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("별점과 리뷰 내용, 사진을 모두 입력해주세요.")));
                  }
                }
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Center(
      child: Column(
        children: [
          RatingBar.builder(
            initialRating: inputRating.toDouble(),
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemSize: 40,
            itemBuilder: (context, index) {
              return Icon(
                index < inputRating
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: Colors.amberAccent,
              );
            },
            onRatingUpdate: (value) {
              setState(() {
                inputRating = value.toInt();
              });
            },
          ),
          const SizedBox(height: 5),
          const Text("별점을 선택해주세요!", style: TextStyle(fontSize: 15)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: AppColor.SocdocBlue,
      thickness: 1.0,
    );
  }

  Widget _buildReviewInput() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: reviewTextController,
            decoration: const InputDecoration(
              hintText: "어떤 점이 좋았는지 혹은 아쉬웠는지\n솔직하게 적어주세요:)",
              hintMaxLines: 2,
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoButton() {
    final ImagePicker picker = ImagePicker();

    return TextButton(
      onPressed: () {},
      child: Container(
        width: 100,
        height: 90,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColor.SocdocBlue,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              picker.pickImage(source: ImageSource.gallery).then((value) async {
                if(await value!.length() < 10000000) {
                  inputPhoto = value;
                  isPhotoLoaded = true;
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("10MB 이하의 사진만 첨부 가능합니다.")));
                }
              });
            });
          },
          child: Column(
            children: [
              Icon(
                isPhotoLoaded ? Icons.check : Icons.add_a_photo,
                color: AppColor.SocdocBlue,
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                isPhotoLoaded ? "사진 추가됨" : "사진 추가",
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColor.SocdocBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
