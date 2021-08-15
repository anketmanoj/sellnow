import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

class ImageSlider extends StatefulWidget {
  const ImageSlider({Key? key}) : super(key: key);

  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  int _index = 0;
  int _dataLength = 1;
  @override
  void initState() {
    getSliderImageFromDb();
    super.initState();
  }

  Future<List<QueryDocumentSnapshot<Object?>>> getSliderImageFromDb() async {
    var _firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await _firestore.collection('slider').get();
    setState(() {
      _dataLength = snapshot.docs.length;
    });
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_dataLength != 0)
          FutureBuilder<List<QueryDocumentSnapshot<Object?>>>(
            future: getSliderImageFromDb(),
            builder: (context, snapshot) {
              return snapshot.data == null
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CarouselSlider.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, int index, _) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Image.network(
                                snapshot.data![index]['image'],
                                fit: BoxFit.fill,
                              ),
                            );
                          },
                          options: CarouselOptions(
                            initialPage: 0,
                            autoPlay: true,
                            height: 150,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _index = index;
                              });
                            },
                          )),
                    );
            },
          ),
        if (_dataLength != 0)
          DotsIndicator(
            dotsCount: _dataLength,
            position: _index.toDouble(),
            decorator: DotsDecorator(
              size: Size.square(5),
              activeSize: Size(9.0, 5.0),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              activeColor: Theme.of(context).primaryColor,
            ),
          ),
      ],
    );
  }
}
