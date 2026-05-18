import '../models/recipe_model.dart';
import '../services/app_images.dart';

class RecipeData {
  static List<Recipe> recipes = [
    // ── Makanan Utama ───────────────────────────────────────────────────────
    Recipe(
      id: '1',
      title: 'Nasi Goreng Spesial',
      description: 'Nasi goreng lezat dengan telur, ayam, dan bumbu rempah pilihan.',
      imageUrl: AppImages.nasiGoreng,
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
      category: 'sarapan',
      youtubeId: 'b7O8j6T-Hsw',
    ),
    Recipe(
      id: '2',
      title: 'Sate Ayam Madura',
      description: 'Sate ayam empuk dengan bumbu kacang yang gurih dan kental.',
      imageUrl: AppImages.sateAyam,
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
      category: 'makan_siang',
    ),
    Recipe(
      id: '3',
      title: 'Rendang Sapi',
      description:
          'Masakan daging sapi tradisional dengan bumbu rempah yang kaya rasa.',
      imageUrl: AppImages.rendangSapi,
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
      category: 'makan_siang',
      youtubeId: 'qQjH8l9V6eA',
    ),

    // ── Sup ─────────────────────────────────────────────────────────────────
    Recipe(
      id: '4',
      title: 'Soto Ayam',
      description:
          'Sup ayam bening khas Indonesia dengan bumbu kunyit dan rempah aromatik.',
      imageUrl: AppImages.soto,
      ingredients: [
        '1 ekor ayam kampung',
        '2 batang serai',
        '3 lembar daun jeruk',
        'Bumbu halus: bawang putih, kunyit, jahe',
        'Tauge, soun, daun bawang',
        'Garam dan merica secukupnya',
      ],
      instructions: [
        'Rebus ayam hingga empuk, angkat dan suwir dagingnya.',
        'Tumis bumbu halus bersama serai dan daun jeruk.',
        'Masukkan kaldu ayam dan bumbu, masak hingga mendidih.',
        'Sajikan dengan soun, tauge, dan daun bawang.',
      ],
      durationMinutes: 60,
      difficulty: 'Menengah',
      category: 'makan_malam',
    ),
    Recipe(
      id: '5',
      title: 'Sup Buntut',
      description:
          'Sup buntut sapi kaya kolagen dengan kuah bening yang gurih dan segar.',
      imageUrl: AppImages.supBuntut,
      ingredients: [
        '1 kg buntut sapi',
        'Wortel, kentang, tomat',
        'Bawang merah, bawang putih',
        'Cengkeh, pala, merica',
        'Garam secukupnya',
        'Bawang goreng untuk taburan',
      ],
      instructions: [
        'Rebus buntut sapi 2-3 jam hingga empuk.',
        'Tumis bawang merah dan putih, masukkan ke dalam rebusan.',
        'Tambahkan wortel, kentang, dan bumbu rempah.',
        'Masak hingga sayuran empuk, koreksi rasa.',
        'Sajikan dengan bawang goreng dan perasan jeruk nipis.',
      ],
      durationMinutes: 180,
      difficulty: 'Menengah',
      category: 'makan_malam',
    ),

    // ── Dessert ──────────────────────────────────────────────────────────────
    Recipe(
      id: '6',
      title: 'Es Krim Kelapa Muda',
      description:
          'Es krim segar berbahan dasar kelapa muda dengan tekstur lembut dan creamy.',
      imageUrl: AppImages.esKrim,
      ingredients: [
        '500ml santan kelapa',
        '200ml susu kental manis',
        '200g daging kelapa muda',
        '100g gula pasir',
        '1 sdt vanili',
        'Sejumput garam',
      ],
      instructions: [
        'Blender santan, susu kental manis, dan gula hingga halus.',
        'Campurkan dengan kelapa muda yang sudah dikeruk.',
        'Masukkan ke dalam wadah dan bekukan selama 2 jam.',
        'Aduk setiap 30 menit agar tidak terbentuk kristal es.',
        'Bekukan hingga set sempurna, sajikan.',
      ],
      durationMinutes: 30,
      difficulty: 'Mudah',
      category: 'camilan',
    ),
    Recipe(
      id: '7',
      title: 'Klepon Pandan',
      description:
          'Kue tradisional bulat isi gula merah dengan balutan kelapa parut harum pandan.',
      imageUrl: AppImages.klepon,
      ingredients: [
        '250g tepung ketan',
        '200ml air pandan',
        '150g gula merah (serut)',
        '200g kelapa parut',
        '1 sdt garam',
      ],
      instructions: [
        'Campur tepung ketan dengan air pandan, uleni hingga kalis.',
        'Ambil sedikit adonan, pipihkan, isi dengan gula merah serut.',
        'Bulatkan adonan, pastikan tidak ada yang bocor.',
        'Rebus dalam air mendidih hingga mengapung.',
        'Gulingkan di atas kelapa parut yang sudah dikukus dengan garam.',
      ],
      durationMinutes: 45,
      difficulty: 'Menengah',
      category: 'camilan',
    ),

    // ── Minuman ──────────────────────────────────────────────────────────────
    Recipe(
      id: '8',
      title: 'Es Teh Tarik',
      description:
          'Minuman teh susu khas yang ditarik berulang untuk menghasilkan buih lembut.',
      imageUrl: AppImages.esTehTarik,
      ingredients: [
        '2 kantong teh hitam',
        '200ml air panas',
        '3 sdm susu kental manis',
        'Es batu secukupnya',
        '1 sdm gula (sesuai selera)',
      ],
      instructions: [
        'Seduh teh hitam dengan air panas selama 5 menit.',
        'Tambahkan susu kental manis dan gula, aduk rata.',
        'Tuang dari gelas ke gelas secara bergantian dari ketinggian untuk membuat buih.',
        'Ulangi proses menarik 3-4 kali.',
        'Sajikan dengan es batu.',
      ],
      durationMinutes: 10,
      difficulty: 'Mudah',
      category: 'minuman',
    ),
    Recipe(
      id: '9',
      title: 'Jus Alpukat Kocok',
      description:
          'Jus alpukat segar yang dikocok bersama susu dan coklat untuk sajian premium.',
      imageUrl: AppImages.jusAlpukat,
      ingredients: [
        '2 buah alpukat matang',
        '200ml susu segar',
        '3 sdm susu kental manis',
        '2 sdm coklat bubuk',
        'Es batu secukupnya',
      ],
      instructions: [
        'Keruk daging alpukat dan masukkan ke blender.',
        'Tambahkan susu segar dan susu kental manis.',
        'Blender hingga halus dan creamy.',
        'Tuang ke gelas berisi es batu.',
        'Tambahkan coklat bubuk di atas sebagai topping.',
      ],
      durationMinutes: 10,
      difficulty: 'Mudah',
      category: 'minuman',
    ),

    // ── Snack ────────────────────────────────────────────────────────────────
    Recipe(
      id: '10',
      title: 'Pisang Goreng Crispy',
      description:
          'Pisang goreng renyah dengan balutan tepung crispy yang garing dan lezat.',
      imageUrl: AppImages.pisangGoreng,
      ingredients: [
        '5 buah pisang kepok',
        '150g tepung terigu',
        '50g tepung beras',
        '1 sdt baking powder',
        'Air dingin secukupnya',
        'Minyak untuk menggoreng',
      ],
      instructions: [
        'Kupas dan belah pisang menjadi dua bagian.',
        'Campurkan tepung terigu, tepung beras, baking powder, dan air dingin.',
        'Aduk adonan hingga kental dan tidak bergerindil.',
        'Celupkan pisang ke dalam adonan hingga merata.',
        'Goreng dalam minyak panas hingga kuning keemasan dan renyah.',
      ],
      durationMinutes: 25,
      difficulty: 'Mudah',
      category: 'camilan',
    ),
    Recipe(
      id: '11',
      title: 'Tahu Crispy Pedas',
      description:
          'Tahu goreng renyah berlapis tepung bumbu yang pedas dan menggoyang lidah.',
      imageUrl: AppImages.tahuCrispy,
      ingredients: [
        '400g tahu putih',
        '100g tepung bumbu serbaguna',
        '1 sdt bubuk cabai',
        '1 sdt bawang putih bubuk',
        'Air secukupnya',
        'Minyak untuk menggoreng',
      ],
      instructions: [
        'Potong tahu menjadi ukuran sedang, tiriskan airnya.',
        'Campur tepung bumbu, bubuk cabai, dan bawang putih bubuk.',
        'Larutkan dengan air hingga adonan sedikit kental.',
        'Celupkan tahu ke adonan, goreng hingga kuning keemasan.',
        'Angkat dan tiriskan, sajikan segera.',
      ],
      durationMinutes: 20,
      difficulty: 'Mudah',
      category: 'camilan',
      youtubeId: '9z8X4-f446I',
    ),
  ];
}
