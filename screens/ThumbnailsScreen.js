import React, {Component} from 'react';
import {NativeModules} from 'react-native';
import {View, StyleSheet, SafeAreaView, FlatList, Text} from 'react-native';

const ThumbnailGenerator = NativeModules.ThumbnailGenerator;

class ThumbnailsScreen extends Component {
  componentDidMount() {
    console.log('>>> componentDidMount');
    // const foo = require('../assets/bubbles.mp4');
    // console.log('>>> ' + foo);
    console.log(ThumbnailGenerator);
    ThumbnailGenerator.foo('../assets/bubbles.mp4', stuff => {
      console.log('>>> stuff: ' + stuff);
    });
    // console.log('>>> bar: ' + bar);
    //   ThumbnailGenerator.generateThumbnails('./')
  }
  render() {
    return (
      <SafeAreaView style={styles.screen}>
        <Text>Thumbnails</Text>
        <FlatList />
      </SafeAreaView>
    );
  }
}

const styles = StyleSheet.create({
  screen: {
    flex: 1,
  },
});

export default ThumbnailsScreen;
