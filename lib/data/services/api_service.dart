import 'package:dio/dio.dart';

class ApiService {
  final Dio dio;

  static const List<Map<String, dynamic>> _staticDestinations = [
    {
      'name': 'Paris, France',
      'location': 'Europe',
      'description': 'The City of Light, famous for the Eiffel Tower, world-class museums like the Louvre, and its romantic atmosphere.',
      'type': 'Cultural',
      'rating': 4.9,
      'lat': 48.8566,
      'lng': 2.3522,
    },
    {
      'name': 'Kyoto, Japan',
      'location': 'Asia',
      'description': 'Known for its classical Buddhist temples, gardens, imperial palaces, Shinto shrines, and traditional wooden houses.',
      'type': 'History',
      'rating': 4.8,
      'lat': 35.0116,
      'lng': 135.7681,
    },
    {
      'name': 'Santorini, Greece',
      'location': 'Europe',
      'description': 'Famous for its stunning sunsets, white-washed buildings with blue domes, and breathtaking views of the Aegean Sea.',
      'type': 'Beach',
      'rating': 4.9,
      'lat': 36.3932,
      'lng': 25.4615,
    },
    {
      'name': 'Bali, Indonesia',
      'location': 'Asia',
      'description': 'A tropical paradise known for its forested volcanic mountains, iconic rice paddies, beaches, and coral reefs.',
      'type': 'Nature',
      'rating': 4.7,
      'lat': -8.4095,
      'lng': 115.1889,
    },
    {
      'name': 'New York City, USA',
      'location': 'North America',
      'description': 'The city that never sleeps, featuring iconic landmarks like Times Square, Central Park, and the Statue of Liberty.',
      'type': 'Metropolis',
      'rating': 4.6,
      'lat': 40.7128,
      'lng': -74.0060,
    },
    {
      'name': 'Rome, Italy',
      'location': 'Europe',
      'description': 'The Eternal City, home to ancient ruins like the Colosseum and the Roman Forum, and world-renowned Italian cuisine.',
      'type': 'History',
      'rating': 4.8,
      'lat': 41.9028,
      'lng': 12.4964,
    },
    {
      'name': 'Reykjavik, Iceland',
      'location': 'Europe',
      'description': 'Gateway to Iceland\'s natural wonders, including geysers, glaciers, waterfalls, and the magical Northern Lights.',
      'type': 'Adventure',
      'rating': 4.7,
      'lat': 64.1265,
      'lng': -21.8174,
    },
    {
      'name': 'Machu Picchu, Peru',
      'location': 'South America',
      'description': 'An Incan citadel set high in the Andes Mountains, famous for its archaeological significance and panoramic views.',
      'type': 'Ancient',
      'rating': 4.9,
      'lat': -13.1631,
      'lng': -72.5450,
    },
    {
      'name': 'Sydney, Australia',
      'location': 'Oceania',
      'description': 'Home to the iconic Opera House and Harbour Bridge, with beautiful beaches and a vibrant outdoor lifestyle.',
      'type': 'City',
      'rating': 4.7,
      'lat': -33.8688,
      'lng': 151.2093,
    },
    {
      'name': 'Cairo, Egypt',
      'location': 'Africa',
      'description': 'Home to the Giza Pyramid Complex and the Great Sphinx, offering a deep dive into ancient civilization.',
      'type': 'History',
      'rating': 4.5,
      'lat': 30.0444,
      'lng': 31.2357,
    },
    {
      'name': 'Cape Town, South Africa',
      'location': 'Africa',
      'description': 'A coastal city known for Table Mountain, Cape Point, and its stunning wine regions.',
      'type': 'Scenery',
      'rating': 4.8,
      'lat': -33.9249,
      'lng': 18.4241,
    },
    {
      'name': 'Dubai, UAE',
      'location': 'Middle East',
      'description': 'Famous for its luxury shopping, ultramodern architecture, and the tallest building in the world, Burj Khalifa.',
      'type': 'Luxury',
      'rating': 4.7,
      'lat': 25.2048,
      'lng': 55.2708,
    },
  ];

  ApiService(this.dio);

  Future<Response> getDestinations() async {
    final response = await dio.get('https://jsonplaceholder.typicode.com/photos?_limit=12');
    
    if (response.statusCode == 200) {
      final List<dynamic> photos = response.data;
      final List<Map<String, dynamic>> mappedData = [];

      for (int i = 0; i < photos.length; i++) {
        final photo = photos[i];
        final staticData = _staticDestinations[i % _staticDestinations.length];
        
        mappedData.add({
          'id': photo['id'],
          'name': staticData['name'],
          'country': staticData['location'],
          'description': staticData['description'],
          'image': 'https://picsum.photos/seed/${photo['id']}/600/400',
          'type': staticData['type'],
          'rating': staticData['rating'],
          'lat': staticData['lat'],
          'lng': staticData['lng'],
        });
      }

      // Wrap in a fake Dio Response to maintain compatibility
      return Response(
        data: mappedData,
        statusCode: 200,
        requestOptions: response.requestOptions,
      );
    }
    return response;
  }

  Future<Response> getWeather(double lat, double lon) async {
    return await dio.get(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon'
      '&current_weather=true'
      '&hourly=relativehumidity_2m'
      '&wind_speed_unit=kmh'
      '&forecast_days=1',
    );
  }
}
