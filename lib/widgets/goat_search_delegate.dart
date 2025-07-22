import 'package:flutter/material.dart';
import 'package:goat_tracker/models/goat.dart';

class GoatSearchDelegate extends SearchDelegate<String> {
  final List<Goat> goats;

  GoatSearchDelegate(this.goats);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(child: Text('Enter a search term'));
    }

    final results = goats.where((goat) {
      final searchLower = query.toLowerCase();
      final tagLower = goat.tagNumber.toLowerCase();
      final nameLower = goat.name.toLowerCase();
      return tagLower.contains(searchLower) || 
             nameLower.contains(searchLower);
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Text('No goats found matching "$query"'),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final goat = results[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(goat.tagNumber[0].toUpperCase()),
          ),
          title: Text(goat.tagNumber),
          subtitle: Text(goat.name),
          onTap: () {
            close(context, goat.tagNumber);
          },
        );
      },
    );
  }
}
