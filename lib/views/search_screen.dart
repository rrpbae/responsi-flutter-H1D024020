import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/location_model.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectLocation(LocationModel location) {
    context.read<WeatherViewModel>().fetchWeather(location);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchVM = context.watch<SearchViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari & Kelola Lokasi'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Input Pencarian
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Ketik nama kota (misal: Jakarta, Purwokerto)...',
                prefixIcon: const Icon(CupertinoIcons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(CupertinoIcons.clear_circled_solid),
                  onPressed: () {
                    _searchController.clear();
                    searchVM.clearSearch();
                  },
                )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                searchVM.search(value);
              },
            ),
          ),

          // Area Konten Berdasarkan State
          Expanded(
            child: _buildBody(context, searchVM),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, SearchViewModel searchVM) {
    final theme = Theme.of(context);

    // 1. Loading State
    if (searchVM.state == SearchState.loading) {
      return const Center(child: CupertinoActivityIndicator(radius: 14));
    }

    // 2. Error State
    if (searchVM.state == SearchState.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.exclamationmark_triangle_fill,
                  size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 12),
              Text(
                'Terjadi Kesalahan',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                searchVM.errorMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Empty Search State (Pencarian tidak ada hasil)
    if (searchVM.state == SearchState.empty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.search,
                size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              'Kota Tidak Ditemukan',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Coba gunakan kata kunci pencarian yang lain.',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    // 4. Success State (Hasil Pencarian dari API)
    if (searchVM.state == SearchState.success) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: searchVM.searchResults.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final location = searchVM.searchResults[index];
          final isFav = searchVM.isLocationFavorite(location);

          return ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            leading: const CircleAvatar(
              child: Icon(CupertinoIcons.location_solid, size: 20),
            ),
            title: Text(
              location.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(location.fullDisplayName),
            trailing: IconButton(
              icon: Icon(
                isFav ? CupertinoIcons.star_fill : CupertinoIcons.star,
                color: isFav ? Colors.amber : theme.colorScheme.outline,
              ),
              tooltip: isFav ? 'Hapus dari Favorit' : 'Simpan ke Favorit',
              onPressed: () {
                searchVM.toggleFavorite(location);
              },
            ),
            onTap: () => _selectLocation(location),
          );
        },
      );
    }

    // 5. Initial State: Menampilkan Daftar Kota Favorit yang Tersimpan
    return _buildFavoritesList(context, searchVM);
  }

  Widget _buildFavoritesList(BuildContext context, SearchViewModel searchVM) {
    final theme = Theme.of(context);
    final favorites = searchVM.favorites;

    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.star,
                size: 48, color: theme.colorScheme.outline.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              'Belum Ada Lokasi Favorit',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Cari kota di atas dan tekan ikon bintang untuk menyimpannya.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Lokasi Favorit Tersimpan',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: favorites.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final location = favorites[index];
              return ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                leading: const CircleAvatar(
                  child: Icon(CupertinoIcons.star_fill,
                      color: Colors.amber, size: 20),
                ),
                title: Text(
                  location.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(location.fullDisplayName),
                trailing: IconButton(
                  icon: const Icon(CupertinoIcons.delete, size: 20),
                  color: theme.colorScheme.error,
                  tooltip: 'Hapus Favorit',
                  onPressed: () {
                    searchVM.toggleFavorite(location);
                  },
                ),
                onTap: () => _selectLocation(location),
              );
            },
          ),
        ),
      ],
    );
  }
}