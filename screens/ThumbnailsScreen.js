import React, {useState} from 'react';
import {
  NativeModules,
  StyleSheet,
  SafeAreaView,
  View,
  FlatList,
  Button,
  Image,
  ActivityIndicator,
} from 'react-native';
import ImagePicker from 'react-native-image-picker';

const ThumbnailGenerator = NativeModules.ThumbnailGenerator;

const renderImageItem = item => {
  return (
    <View style={styles.imageContainer}>
      <Image style={styles.image} source={{uri: item.item}} />
    </View>
  );
};
const ThumbnailsScreen = props => {
  const [images, setImages] = useState([]);
  const [isLoading, setIsLoading] = useState(false);

  const videoSelectedHandler = uri => {
    setIsLoading(true);
    ThumbnailGenerator.generateThumbnails(uri, (error, result) => {
      console.log('>>> error: ', error);
      console.log('>>> result: ', result);
      if (result != null) {
        setIsLoading(false);
        setImages(result);
      }
    });
  };

  const buttonHeader = () => {
    const options = {
      mediaType: 'video',
    };
    return (
      <Button
        title="Pick a video"
        onPress={() => {
          ImagePicker.launchImageLibrary(options, response => {
            videoSelectedHandler(response.uri);
          });
        }}
      />
    );
  };

  return (
    <SafeAreaView style={styles.screen}>
      <ActivityIndicator animating={isLoading} />
      <FlatList
        ListHeaderComponent={buttonHeader}
        keyExtractor={(item, index) => {
          return item;
        }}
        data={images}
        renderItem={renderImageItem}
      />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  screen: {
    flex: 1,
  },
  imageContainer: {
    flex: 1,
    height: 150,
    padding: 5,
  },
  image: {
    width: '100%',
    height: '100%',
    resizeMode: 'cover',
  },
});

export default ThumbnailsScreen;
