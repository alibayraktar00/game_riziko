import '../../domain/entities/question.dart';
import '../../domain/repositories/question_repository.dart';
import '../models/question_model.dart';

import '../../services/custom_content_service.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final CustomContentService _customContentService;
  
  static final List<Map<String, dynamic>> _mockQuestionsJson = _buildQuestions();

  QuestionRepositoryImpl(this._customContentService);

  static List<Map<String, dynamic>> _buildQuestions() {
    return [
      // ───────────────── BİLİM / SCIENCE ─────────────────
      {
        'id': 'sci_1',
        'category': 'Science',
        'difficulty': 1,
        'translations': {
          'en': 'What is the chemical symbol for water?',
          'tr': 'Suyun kimyasal sembolü nedir?',
        },
        'answers': ['h2o'],
        'keywords': ['h2o'],
      },
      {
        'id': 'sci_2',
        'category': 'Science',
        'difficulty': 1,
        'translations': {
          'en': 'How many legs does a spider have?',
          'tr': 'Bir örümceğin kaç bacağı vardır?',
        },
        'answers': ['8', 'eight', 'sekiz'],
        'keywords': ['8'],
      },
      {
        'id': 'sci_3',
        'category': 'Science',
        'difficulty': 2,
        'translations': {
          'en': 'What planet is known as the Red Planet?',
          'tr': 'Hangi gezegen Kızıl Gezegen olarak bilinir?',
        },
        'answers': ['mars'],
        'keywords': ['mars'],
      },
      {
        'id': 'sci_4',
        'category': 'Science',
        'difficulty': 2,
        'translations': {
          'en': 'What is the powerhouse of the cell?',
          'tr': 'Hücrenin enerji merkezi hangisidir?',
        },
        'answers': ['mitochondria', 'mitokondri'],
        'keywords': ['mitochondria', 'mitokondri'],
      },
      {
        'id': 'sci_5',
        'category': 'Science',
        'difficulty': 3,
        'translations': {
          'en': 'What is the speed of light in km/s?',
          'tr': 'Işığın hızı km/s cinsinden kaçtır?',
        },
        'answers': ['300000', '299792'],
        'keywords': ['300000'],
      },
      {
        'id': 'sci_6',
        'category': 'Science',
        'difficulty': 3,
        'translations': {
          'en': 'What gas do plants absorb from the atmosphere?',
          'tr': 'Bitkiler atmosferden hangi gazı emerler?',
        },
        'answers': ['carbon dioxide', 'co2', 'karbondioksit'],
        'keywords': ['co2', 'carbon dioxide', 'karbondioksit'],
      },
      {
        'id': 'sci_7',
        'category': 'Science',
        'difficulty': 4,
        'translations': {
          'en': 'What is the atomic number of carbon?',
          'tr': 'Karbonun atom numarası kaçtır?',
        },
        'answers': ['6', 'six', 'altı'],
        'keywords': ['6'],
      },
      {
        'id': 'sci_8',
        'category': 'Science',
        'difficulty': 4,
        'translations': {
          'en': 'Which scientist proposed the theory of relativity?',
          'tr': 'Görelilik teorisini hangi bilim insanı öne sürdü?',
        },
        'answers': ['einstein', 'albert einstein'],
        'keywords': ['einstein'],
      },
      {
        'id': 'sci_9',
        'category': 'Science',
        'difficulty': 5,
        'translations': {
          'en': 'What is the half-life of Carbon-14?',
          'tr': 'Karbon-14\'ün yarı ömrü ne kadardır?',
        },
        'answers': ['5730 years', '5730 yıl', '5730'],
        'keywords': ['5730'],
      },
      {
        'id': 'sci_10',
        'category': 'Science',
        'difficulty': 5,
        'translations': {
          'en': 'What particle has no charge and is found in the nucleus?',
          'tr': 'Çekirdekte bulunan ve yükü olmayan parçacık hangisidir?',
        },
        'answers': ['neutron', 'nötron'],
        'keywords': ['neutron', 'nötron'],
      },

      // ───────────────── TARİH / HISTORY ─────────────────
      {
        'id': 'his_1',
        'category': 'History',
        'difficulty': 1,
        'translations': {
          'en': 'In which year did World War II end?',
          'tr': '2. Dünya Savaşı hangi yılda sona erdi?',
        },
        'answers': ['1945'],
        'keywords': ['1945'],
      },
      {
        'id': 'his_2',
        'category': 'History',
        'difficulty': 1,
        'translations': {
          'en': 'Who was the first President of the United States?',
          'tr': 'Amerika Birleşik Devletleri\'nin ilk Başkanı kimdir?',
        },
        'answers': ['george washington', 'washington'],
        'keywords': ['washington'],
      },
      {
        'id': 'his_3',
        'category': 'History',
        'difficulty': 2,
        'translations': {
          'en': 'In which year did the Turkish Republic be founded?',
          'tr': 'Türkiye Cumhuriyeti hangi yılda kuruldu?',
        },
        'answers': ['1923'],
        'keywords': ['1923'],
      },
      {
        'id': 'his_4',
        'category': 'History',
        'difficulty': 2,
        'translations': {
          'en': 'Who was the founder of the Ottoman Empire?',
          'tr': 'Osmanlı İmparatorluğu\'nun kurucusu kimdir?',
        },
        'answers': ['osman', 'osman i', 'osman gazi'],
        'keywords': ['osman'],
      },
      {
        'id': 'his_5',
        'category': 'History',
        'difficulty': 3,
        'translations': {
          'en': 'Which ancient wonder of the world still stands today?',
          'tr': 'Dünyanın yedi harikasından hangisi bugün hâlâ ayaktadır?',
        },
        'answers': ['great pyramid', 'pyramid of giza', 'giza'],
        'keywords': ['pyramid', 'giza'],
      },
      {
        'id': 'his_6',
        'category': 'History',
        'difficulty': 3,
        'translations': {
          'en': 'In which year did the Berlin Wall fall?',
          'tr': 'Berlin Duvarı hangi yılda yıkıldı?',
        },
        'answers': ['1989'],
        'keywords': ['1989'],
      },
      {
        'id': 'his_7',
        'category': 'History',
        'difficulty': 4,
        'translations': {
          'en': 'Who wrote "The Art of War"?',
          'tr': '"Savaş Sanatı" adlı eseri kim yazmıştır?',
        },
        'answers': ['sun tzu', 'sun tzu'],
        'keywords': ['sun tzu'],
      },
      {
        'id': 'his_8',
        'category': 'History',
        'difficulty': 4,
        'translations': {
          'en': 'The Byzantine Empire fell in which year?',
          'tr': 'Bizans İmparatorluğu hangi yılda yıkıldı?',
        },
        'answers': ['1453'],
        'keywords': ['1453'],
      },
      {
        'id': 'his_9',
        'category': 'History',
        'difficulty': 5,
        'translations': {
          'en': 'Who was the Egyptian pharaoh during the Battle of Kadesh?',
          'tr': 'Kadeş Savaşı sırasında Mısır\'ın firavunu kimdi?',
        },
        'answers': ['ramesses', 'ramesses ii', 'ramses'],
        'keywords': ['ramesses', 'ramses'],
      },
      {
        'id': 'his_10',
        'category': 'History',
        'difficulty': 5,
        'translations': {
          'en': 'In which year was the Magna Carta signed?',
          'tr': 'Magna Carta hangi yılda imzalandı?',
        },
        'answers': ['1215'],
        'keywords': ['1215'],
      },

      // ───────────────── COĞRAFYA / GEOGRAPHY ─────────────────
      {
        'id': 'geo_1',
        'category': 'Geography',
        'difficulty': 1,
        'translations': {
          'en': 'What is the capital of France?',
          'tr': 'Fransa\'nın başkenti neresidir?',
        },
        'answers': ['paris'],
        'keywords': ['paris'],
      },
      {
        'id': 'geo_2',
        'category': 'Geography',
        'difficulty': 1,
        'translations': {
          'en': 'Which is the largest ocean on Earth?',
          'tr': 'Dünya\'daki en büyük okyanus hangisidir?',
        },
        'answers': ['pacific', 'pacific ocean', 'büyük okyanus'],
        'keywords': ['pacific'],
      },
      {
        'id': 'geo_3',
        'category': 'Geography',
        'difficulty': 2,
        'translations': {
          'en': 'What is the longest river in the world?',
          'tr': 'Dünyanın en uzun nehri hangisidir?',
        },
        'answers': ['nile', 'nil'],
        'keywords': ['nile', 'nil'],
      },
      {
        'id': 'geo_4',
        'category': 'Geography',
        'difficulty': 2,
        'translations': {
          'en': 'Which country has the most natural lakes?',
          'tr': 'En fazla doğal göle sahip ülke hangisidir?',
        },
        'answers': ['canada', 'kanada'],
        'keywords': ['canada', 'kanada'],
      },
      {
        'id': 'geo_5',
        'category': 'Geography',
        'difficulty': 3,
        'translations': {
          'en': 'What is the capital of Australia?',
          'tr': 'Avustralya\'nın başkenti neresidir?',
        },
        'answers': ['canberra'],
        'keywords': ['canberra'],
      },
      {
        'id': 'geo_6',
        'category': 'Geography',
        'difficulty': 3,
        'translations': {
          'en': 'Which desert is the largest in the world?',
          'tr': 'Dünyanın en büyük çölü hangisidir?',
        },
        'answers': ['sahara', 'sahara desert'],
        'keywords': ['sahara'],
      },
      {
        'id': 'geo_7',
        'category': 'Geography',
        'difficulty': 4,
        'translations': {
          'en': 'Which country has the longest coastline?',
          'tr': 'En uzun kıyı şeridine sahip ülke hangisidir?',
        },
        'answers': ['canada', 'kanada'],
        'keywords': ['canada', 'kanada'],
      },
      {
        'id': 'geo_8',
        'category': 'Geography',
        'difficulty': 4,
        'translations': {
          'en': 'What is the smallest country in the world?',
          'tr': 'Dünyanın en küçük ülkesi neresidir?',
        },
        'answers': ['vatican', 'vatican city', 'vatikan'],
        'keywords': ['vatican', 'vatikan'],
      },
      {
        'id': 'geo_9',
        'category': 'Geography',
        'difficulty': 5,
        'translations': {
          'en': 'What is the deepest lake in the world?',
          'tr': 'Dünyanın en derin gölü hangisidir?',
        },
        'answers': ['baikal', 'lake baikal', 'baykal'],
        'keywords': ['baikal', 'baykal'],
      },
      {
        'id': 'geo_10',
        'category': 'Geography',
        'difficulty': 5,
        'translations': {
          'en': 'Which mountain range separates Europe from Asia?',
          'tr': 'Avrupa\'yı Asya\'dan ayıran dağ silsilesi hangisidir?',
        },
        'answers': ['ural', 'ural mountains', 'ural dağları'],
        'keywords': ['ural'],
      },

      // ───────────────── SPOR / SPORTS ─────────────────
      {
        'id': 'spt_1',
        'category': 'Sports',
        'difficulty': 1,
        'translations': {
          'en': 'How many players are on a football (soccer) team on the field?',
          'tr': 'Sahada bir futbol takımında kaç oyuncu bulunur?',
        },
        'answers': ['11', 'eleven', 'on bir'],
        'keywords': ['11'],
      },
      {
        'id': 'spt_2',
        'category': 'Sports',
        'difficulty': 1,
        'translations': {
          'en': 'In which sport is the term "slam dunk" used?',
          'tr': '"Slam dunk" terimi hangi sporda kullanılır?',
        },
        'answers': ['basketball', 'basketbol'],
        'keywords': ['basketball', 'basketbol'],
      },
      {
        'id': 'spt_3',
        'category': 'Sports',
        'difficulty': 2,
        'translations': {
          'en': 'Which country has won the most FIFA World Cups?',
          'tr': 'En fazla FIFA Dünya Kupası kazanan ülke hangisidir?',
        },
        'answers': ['brazil', 'brezilya'],
        'keywords': ['brazil', 'brezilya'],
      },
      {
        'id': 'spt_4',
        'category': 'Sports',
        'difficulty': 2,
        'translations': {
          'en': 'How many rings are on the Olympic flag?',
          'tr': 'Olimpiyat bayrağında kaç halka vardır?',
        },
        'answers': ['5', 'five', 'beş'],
        'keywords': ['5'],
      },
      {
        'id': 'spt_5',
        'category': 'Sports',
        'difficulty': 3,
        'translations': {
          'en': 'In which year were the first modern Olympic Games held?',
          'tr': 'İlk modern Olimpiyat Oyunları hangi yılda düzenlendi?',
        },
        'answers': ['1896'],
        'keywords': ['1896'],
      },
      {
        'id': 'spt_6',
        'category': 'Sports',
        'difficulty': 3,
        'translations': {
          'en': 'Which tennis player has won the most Grand Slam titles (male)?',
          'tr': 'En fazla Grand Slam şampiyonluğu kazanan erkek tenisçi kimdir?',
        },
        'answers': ['djokovic', 'novak djokovic'],
        'keywords': ['djokovic'],
      },
      {
        'id': 'spt_7',
        'category': 'Sports',
        'difficulty': 4,
        'translations': {
          'en': 'What is the maximum score in a single game of bowling?',
          'tr': 'Bowling\'de tek bir oyunda alınabilecek maksimum puan kaçtır?',
        },
        'answers': ['300'],
        'keywords': ['300'],
      },
      {
        'id': 'spt_8',
        'category': 'Sports',
        'difficulty': 4,
        'translations': {
          'en': 'Which Formula 1 driver has the most world championships?',
          'tr': 'En fazla Formula 1 Dünya Şampiyonluğu kazanan pilot kimdir?',
        },
        'answers': ['hamilton', 'lewis hamilton', 'schumacher', 'michael schumacher'],
        'keywords': ['hamilton', 'schumacher'],
      },
      {
        'id': 'spt_9',
        'category': 'Sports',
        'difficulty': 5,
        'translations': {
          'en': 'What is the length of a standard marathon in kilometers?',
          'tr': 'Standart bir maratonun uzunluğu kaç kilometredir?',
        },
        'answers': ['42.195', '42', '42 km'],
        'keywords': ['42'],
      },
      {
        'id': 'spt_10',
        'category': 'Sports',
        'difficulty': 5,
        'translations': {
          'en': 'In basketball, how many seconds does a team have to shoot?',
          'tr': 'Basketbolda bir takımın kaç saniyede atış yapması gerekir?',
        },
        'answers': ['24', 'twenty four', 'yirmi dört'],
        'keywords': ['24'],
      },

      // ───────────────── EĞLENCE / ENTERTAINMENT ─────────────────
      {
        'id': 'ent_1',
        'category': 'Entertainment',
        'difficulty': 1,
        'translations': {
          'en': 'Who played Iron Man in the Marvel Cinematic Universe?',
          'tr': 'Marvel Sinematik Evreni\'nde Iron Man\'i kim canlandırdı?',
        },
        'answers': ['robert downey jr', 'robert downey', 'rdj'],
        'keywords': ['downey'],
      },
      {
        'id': 'ent_2',
        'category': 'Entertainment',
        'difficulty': 1,
        'translations': {
          'en': 'How many Harry Potter books are there?',
          'tr': 'Kaç tane Harry Potter kitabı vardır?',
        },
        'answers': ['7', 'seven', 'yedi'],
        'keywords': ['7'],
      },
      {
        'id': 'ent_3',
        'category': 'Entertainment',
        'difficulty': 2,
        'translations': {
          'en': 'Which band performed "Bohemian Rhapsody"?',
          'tr': '"Bohemian Rhapsody"yi hangi grup seslendirdi?',
        },
        'answers': ['queen'],
        'keywords': ['queen'],
      },
      {
        'id': 'ent_4',
        'category': 'Entertainment',
        'difficulty': 2,
        'translations': {
          'en': 'What is the highest-grossing film of all time (not adjusted for inflation)?',
          'tr': 'Tüm zamanların en yüksek hasılat yapan filmi hangisidir (enflasyona göre düzeltilmemiş)?',
        },
        'answers': ['avatar'],
        'keywords': ['avatar'],
      },
      {
        'id': 'ent_5',
        'category': 'Entertainment',
        'difficulty': 3,
        'translations': {
          'en': 'Who directed the movie "Inception"?',
          'tr': '"Inception" filmini kim yönetti?',
        },
        'answers': ['christopher nolan', 'nolan'],
        'keywords': ['nolan'],
      },
      {
        'id': 'ent_6',
        'category': 'Entertainment',
        'difficulty': 3,
        'translations': {
          'en': 'In which fictional city does Batman live?',
          'tr': 'Batman hangi kurgusal şehirde yaşar?',
        },
        'answers': ['gotham', 'gotham city'],
        'keywords': ['gotham'],
      },
      {
        'id': 'ent_7',
        'category': 'Entertainment',
        'difficulty': 4,
        'translations': {
          'en': 'Which artist has the most Grammy Award wins?',
          'tr': 'En fazla Grammy Ödülü kazanan sanatçı kimdir?',
        },
        'answers': ['beyonce', 'beyoncé'],
        'keywords': ['beyonce', 'beyoncé'],
      },
      {
        'id': 'ent_8',
        'category': 'Entertainment',
        'difficulty': 4,
        'translations': {
          'en': 'What is the name of the fictional kingdom in "Frozen"?',
          'tr': '"Frozen" filmindeki kurgusal krallığın adı nedir?',
        },
        'answers': ['arendelle'],
        'keywords': ['arendelle'],
      },
      {
        'id': 'ent_9',
        'category': 'Entertainment',
        'difficulty': 5,
        'translations': {
          'en': 'Which film won the first Academy Award for Best Picture?',
          'tr': 'İlk En İyi Film Oscar\'ını hangi film kazandı?',
        },
        'answers': ['wings', 'kanatlar'],
        'keywords': ['wings'],
      },
      {
        'id': 'ent_10',
        'category': 'Entertainment',
        'difficulty': 5,
        'translations': {
          'en': 'What year was the first iPhone released?',
          'tr': 'İlk iPhone hangi yılda piyasaya sürüldü?',
        },
        'answers': ['2007'],
        'keywords': ['2007'],
      },

      // ───────────────── SANAT / ART ─────────────────
      {
        'id': 'art_1',
        'category': 'Art',
        'difficulty': 1,
        'translations': {
          'en': 'Who painted the "Mona Lisa"?',
          'tr': '"Mona Lisa" tablosunu kim yapmıştır?',
        },
        'answers': ['da vinci', 'leonardo da vinci'],
        'keywords': ['da vinci'],
      },
      {
        'id': 'art_2',
        'category': 'Art',
        'difficulty': 2,
        'translations': {
          'en': 'Which Dutch artist painted "The Starry Night"?',
          'tr': '"Yıldızlı Gece" tablosu hangi Hollandalı ressama aittir?',
        },
        'answers': ['van gogh', 'vincent van gogh'],
        'keywords': ['van gogh'],
      },
      {
        'id': 'art_3',
        'category': 'Art',
        'difficulty': 3,
        'translations': {
          'en': 'Who painted "The Last Supper"?',
          'tr': '"Son Akşam Yemeği" tablosunu kim yapmıştır?',
        },
        'answers': ['da vinci', 'leonardo da vinci'],
        'keywords': ['da vinci'],
      },
      {
        'id': 'art_4',
        'category': 'Art',
        'difficulty': 4,
        'translations': {
          'en': 'Who is the famous Spanish surrealist painter known for melting clocks?',
          'tr': 'Eriyen saatler tablosuyla tanınan ünlü İspanyol sürrealist ressam kimdir?',
        },
        'answers': ['dali', 'salvador dali'],
        'keywords': ['dali'],
      },
      {
        'id': 'art_5',
        'category': 'Art',
        'difficulty': 5,
        'translations': {
          'en': 'Who sculpted the statue of "David"?',
          'tr': '"Davut" heykelini kim yapmıştır?',
        },
        'answers': ['michelangelo'],
        'keywords': ['michelangelo'],
      },

      // ───────────────── TEKNOLOJİ / TECHNOLOGY ─────────────────
      {
        'id': 'tech_1',
        'category': 'Technology',
        'difficulty': 1,
        'translations': {
          'en': 'What does "WWW" stand for?',
          'tr': '"WWW" neyin kısaltmasıdır?',
        },
        'answers': ['world wide web'],
        'keywords': ['world wide web'],
      },
      {
        'id': 'tech_2',
        'category': 'Technology',
        'difficulty': 2,
        'translations': {
          'en': 'Who is the co-founder of Microsoft?',
          'tr': 'Microsoft\'un kurucu ortağı kimdir?',
        },
        'answers': ['bill gates', 'paul allen'],
        'keywords': ['bill gates', 'paul allen'],
      },
      {
        'id': 'tech_3',
        'category': 'Technology',
        'difficulty': 3,
        'translations': {
          'en': 'What is the main language used for Android development?',
          'tr': 'Android geliştirme için kullanılan ana dil hangisidir?',
        },
        'answers': ['kotlin', 'java'],
        'keywords': ['kotlin', 'java'],
      },
      {
        'id': 'tech_4',
        'category': 'Technology',
        'difficulty': 4,
        'translations': {
          'en': 'What does "AI" stand for?',
          'tr': '"AI" neyin kısaltmasıdır?',
        },
        'answers': ['artificial intelligence', 'yapay zeka'],
        'keywords': ['artificial intelligence', 'yapay zeka'],
      },
      {
        'id': 'tech_5',
        'category': 'Technology',
        'difficulty': 5,
        'translations': {
          'en': 'Who is known as the father of computers?',
          'tr': 'Bilgisayarın babası olarak kim bilinir?',
        },
        'answers': ['charles babbage'],
        'keywords': ['babbage'],
      },

      // ───────────────── GENEL KÜLTÜR / GENERAL CULTURE ─────────────────
      {
        'id': 'gen_1',
        'category': 'General Culture',
        'difficulty': 1,
        'translations': {
          'en': 'How many colors are there in a rainbow?',
          'tr': 'Gökkuşağında kaç renk vardır?',
        },
        'answers': ['7', 'seven', 'yedi'],
        'keywords': ['7'],
      },
      {
        'id': 'gen_2',
        'category': 'General Culture',
        'difficulty': 2,
        'translations': {
          'en': 'Which is the largest animal on Earth?',
          'tr': 'Dünyadaki en büyük hayvan hangisidir?',
        },
        'answers': ['blue whale', 'mavi balina'],
        'keywords': ['blue whale', 'mavi balina'],
      },
      {
        'id': 'gen_3',
        'category': 'General Culture',
        'difficulty': 3,
        'translations': {
          'en': 'Which country is known as the Land of the Rising Sun?',
          'tr': 'Hangi ülke Doğan Güneşin Ülkesi olarak bilinir?',
        },
        'answers': ['japan', 'japonya'],
        'keywords': ['japan', 'japonya'],
      },
      {
        'id': 'gen_4',
        'category': 'General Culture',
        'difficulty': 4,
        'translations': {
          'en': 'What is the currency of Japan?',
          'tr': 'Japonya\'nın para birimi nedir?',
        },
        'answers': ['yen'],
        'keywords': ['yen'],
      },
      {
        'id': 'gen_5',
        'category': 'General Culture',
        'difficulty': 5,
        'translations': {
          'en': 'Which language has the most native speakers?',
          'tr': 'En fazla anadili konuşan sayısına sahip dil hangisidir?',
        },
        'answers': ['mandarin', 'chinese', 'çince'],
        'keywords': ['mandarin', 'chinese', 'çince'],
      },
    ];
  }

  @override
  Future<List<Question>> getQuestions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final builtIn = _mockQuestionsJson.map((json) {
      return QuestionModel.fromJson(json, json['id'] as String);
    }).toList();
    
    final custom = _customContentService.getCustomQuestions();
    
    return [...builtIn, ...custom];
  }
}
