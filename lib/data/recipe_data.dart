import '../models/recipe_model.dart';

class RecipeData {
  static List<Recipe> recipes = [
    Recipe(
      id: '1',
      title: 'Nasi Goreng Spesial',
      description: 'Nasi goreng lezat dengan telur, ayam, dan bumbu rempah pilihan.',
      imageUrl: 'https://images.unsplash.com/photo-1512058560366-c80b2016334d?auto=format&fit=crop&q=80&w=800',
      ingredients: [
        '2 piring nasi putih',
        '2 butir telur',
        '100g daging ayam (potong dadu)',
        '3 siung bawang merah',
        '2 siung bawang putih',
        'Kecap manis secukupnya',
        'Garam dan merica secukupnya',
      ],
      instructions: [
        'Tumis bawang merah dan putih hingga harum.',
        'Masukkan daging ayam, masak hingga berubah warna.',
        'Masukkan telur, buat orak-arik.',
        'Tambahkan nasi putih, aduk rata.',
        'Tambahkan kecap manis, garam, dan merica. Aduk hingga bumbu meresap.',
        'Sajikan selagi hangat.',
      ],
      durationMinutes: 20,
      difficulty: 'Mudah',
    ),
    Recipe(
      id: '2',
      title: 'Sate Ayam Madura',
      description: 'Sate ayam empuk dengan bumbu kacang yang gurih dan kental.',
      imageUrl: 'https://images.unsplash.com/photo-1529692236671-f1f6cf9581f5?auto=format&fit=crop&q=80&w=800',
      ingredients: [
        '500g fillet dada ayam',
        '200g kacang tanah goreng',
        '3 siung bawang putih',
        '4 siung bawang merah',
        '3 butir kemiri',
        'Kecap manis secukupnya',
        'Tusuk sate secukupnya',
      ],
      instructions: [
        'Potong ayam menjadi dadu kecil, tusuk dengan lidi sate.',
        'Haluskan kacang tanah, bawang merah, bawang putih, dan kemiri.',
        'Masak bumbu kacang dengan sedikit air dan kecap manis hingga kental.',
        'Bakar sate ayam sambil diolesi bumbu kacang.',
        'Sajikan dengan sisa bumbu kacang dan irisan bawang merah.',
      ],
      durationMinutes: 45,
      difficulty: 'Menengah',
    ),
    Recipe(
      id: '3',
      title: 'Rendang Sapi',
      description: 'Masakan daging sapi tradisional dengan bumbu rempah yang kaya rasa.',
      imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&q=80&w=800',
      ingredients: [
        '500g daging sapi',
        '1 liter santan kental',
        'Bumbu halus (cabai, bawang, jahe, lengkuas)',
        'Daun kunyit, daun jeruk, serai',
        'Asam kandis',
      ],
      instructions: [
        'Rebus santan dengan bumbu halus dan dedaunan hingga mendidih.',
        'Masukkan daging sapi, kecilkan api.',
        'Masak sambil terus diaduk hingga santan berminyak dan bumbu meresap ke daging.',
        'Masak hingga bumbu berwarna cokelat gelap.',
      ],
      durationMinutes: 180,
      difficulty: 'Sulit',
    ),
  ];
}
