import React from 'react';
import {
  NativeModules,
  StyleSheet,
  SafeAreaView,
  FlatList,
  Button,
} from 'react-native';
import ImagePicker from 'react-native-image-picker';

const ThumbnailGenerator = NativeModules.ThumbnailGenerator;

const videoSelectedHandler = uri => {
  ThumbnailGenerator.generateThumbnails(uri, (error, result) => {
    console.log('>>> error: ', error);
    console.log('>>> result: ', result);
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
const ThumbnailsScreen = props => {
  return (
    <SafeAreaView style={styles.screen}>
      <FlatList ListHeaderComponent={buttonHeader} />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  screen: {
    flex: 1,
  },
});

export default ThumbnailsScreen;
