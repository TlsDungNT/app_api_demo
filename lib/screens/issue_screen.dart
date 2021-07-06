import 'package:app_api_demo/blocs/issue_bloc.dart';
import 'package:app_api_demo/models/issue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IssueScreen extends StatefulWidget {
  const IssueScreen({Key? key}) : super(key: key);

  @override
  _IssueScreenState createState() => _IssueScreenState();
}

class _IssueScreenState extends State<IssueScreen> {
  var issues = <Issue>[];
  late var bloc = IssueBloc();
  int _offset = 0;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  GlobalKey _contentKey = GlobalKey();
  GlobalKey _refreshKey = GlobalKey();

  @override
  void initState() {
    bloc.getIssue(limit: 5, offset: 0);
    // TODO: implement initState
    super.initState();
  }

  void _onRefresh() async {
    print('_onRefresh');
    bloc = IssueBloc();
    _offset = 0;
    await Future.delayed(Duration(seconds: 2));
    bloc.getIssue(limit: 5, offset: 0);
    setState(() {
      _refreshController.refreshCompleted();
    });
    print('_onRefresh size: ${bloc.issues.length}');
  }

  void _onLoading() async {
    print('_onLoading');
    _offset += 5;
    bloc.addListIssue(limit: 5, offset: _offset);
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _refreshController.loadComplete();
    });
    print('_onLoading size: ${bloc.issues.length}');
  }

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration.copyAncestor(
      enableLoadingWhenFailed: true,
      context: context,
      child: Scaffold(
        body: SafeArea(
          child: buildBody(),
        ),
      ),
      headerBuilder: () => WaterDropMaterialHeader(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      footerTriggerDistance: 30,
    );
  }

  Widget buildListItem() {
    return ListView.builder(
      key: _contentKey,
      itemBuilder: (ctx, index) {
        final issue = issues[index];
        return buildIssueItem(issue);
      },
      itemCount: issues.length,
    );
  }

  Widget buildBody() {
    return StreamBuilder<List<Issue>>(
      stream: bloc.stream,
      builder: (ctx, snapshot) {
        print('${snapshot.data}');
        if (snapshot.hasData) {
          final issuesLoading = snapshot.data!;
          print('issuesLoading size ${issuesLoading.length}');
          return SmartRefresher(
            key: _refreshKey,
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: true,
            child: ListView.builder(
              key: _contentKey,
              itemBuilder: (ctx, index) {
                final issue = issuesLoading[index];
                return buildIssueItem(issue);
              },
              itemCount: issuesLoading.length,
            ),
            physics: BouncingScrollPhysics(),
            footer: ClassicFooter(
              loadStyle: LoadStyle.ShowWhenLoading,
            ),
            onRefresh: _onRefresh,
            onLoading: _onLoading,
          );
        }
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget buildIssueItem(Issue issue) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(25, 1, 52, 0.12),
            blurRadius: 2,
            spreadRadius: 0,
            offset: Offset(0, 1),
          )
        ],
      ),
      child: Column(
        children: [
          buildAccountPublic(issue),
          buildLineSpace(),
          buildContentIssue(issue),
        ],
      ),
    );
  }

  Widget buildAccountPublic(Issue issue) {
    return Row(
      children: [
        buildAvatar(issue.accountPublic!.avatar),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${issue.accountPublic!.name}",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              Text(
                "${issue.createdAt}",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
        Column(
          children: [
            buildStatusAccount(status: issue.status!),
            Text(""),
          ],
        )
      ],
    );
  }

  Widget buildStatusAccount({required int status}){
    switch(status){
      case 0:
        return Text("Đang chờ", style: TextStyle(fontSize: 16, color: Colors.orange[400]), );
      case 1:
        return Text("Đang xử lý", style: TextStyle(fontSize: 16, color: Colors.green[400]), );
      case 2:
        return Text("Đã xong", style: TextStyle(fontSize: 16, color: Colors.blue[400]), );
      case 3:
        return Text("Huỷ bỏ", style: TextStyle(fontSize: 16, color: Colors.black87), );
      case 4:
        return Text("Không duyệt", style: TextStyle(fontSize: 16, color: Colors.red[400]), );
      default:
        return Text("Không duyệt", style: TextStyle(fontSize: 16, color: Colors.red[400]), );
    }
  }

  Widget buildAvatar(String? url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(color: Colors.blueAccent),
          child: Image.network(
            "http://report.bekhoe.vn$url",
            fit: BoxFit.cover,
          )),
    );
  }

  Widget buildLineSpace() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 1,
      width: double.infinity,
      color: Colors.black38,
    );
  }

  Widget buildContentIssue(Issue issue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${issue.title}",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          '${issue.content}',
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        buildImagesContentGrid(lstPhotos: issue.photos!),
      ],
    );
  }

  Widget buildImagesContentGrid({required List<String> lstPhotos}) {
    return Container(
      child: StaggeredGridView.countBuilder(
        crossAxisCount: lstPhotos.length <= 4 && lstPhotos.length > 0
            ? lstPhotos.length
            : 4,
        // crossAxisCount: 3,
        itemCount: lstPhotos.length <= 4 ? lstPhotos.length : 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        staggeredTileBuilder: (int index) {
          if (lstPhotos.length < 4 ) {
            return StaggeredTile.count(1, 1);
          } else {
            return StaggeredTile.count(2, 2);
          }
        },
        itemBuilder: (ctx, index) {
          return buildImagesContentItem(
              lstPhotos[index], lstPhotos.length, index);
        },
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
      ),
    );
  }

  Widget buildImagesContentItem(String url, int numberList, int index) {
    if (numberList > 4 && index == 3) {
      return Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Image.network(
              'http://report.bekhoe.vn$url',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black38,
            ),
          ),
          Center(
            child: Container(
              child: Text(
                ' + ${numberList - 4}',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          )
        ],
      );
    } else {
      return Container(
        child: FadeInImage.assetNetwork(
          placeholder: "assets/loadding.gif",
          image: "http://report.bekhoe.vn$url",
          fit: BoxFit.cover,
        ),
      );
    }
  }
}
