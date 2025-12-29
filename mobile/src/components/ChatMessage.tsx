import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Message } from '../types/chat';

interface ChatMessageProps {
  message: Message;
}

function formatTime(date: Date): string {
  return date.toLocaleTimeString('fr-FR', {
    hour: '2-digit',
    minute: '2-digit',
  });
}

export default function ChatMessage({ message }: ChatMessageProps) {
  const isUser = message.sender === 'user';

  return (
    <View style={[styles.wrapper, isUser ? styles.wrapperUser : styles.wrapperBot]}>
      <View style={[styles.bubble, isUser ? styles.bubbleUser : styles.bubbleBot]}>
        <Text style={[styles.content, isUser ? styles.contentUser : styles.contentBot]}>
          {message.content}
        </Text>
        <View style={styles.meta}>
          <Text style={[styles.time, isUser ? styles.timeUser : styles.timeBot]}>
            {formatTime(new Date(message.timestamp))}
          </Text>
          {isUser && (
            <Ionicons name="checkmark-done" size={16} color="#34D399" />
          )}
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrapper: {
    paddingHorizontal: 12,
    paddingVertical: 2,
  },
  wrapperUser: {
    alignItems: 'flex-end',
  },
  wrapperBot: {
    alignItems: 'flex-start',
  },
  bubble: {
    maxWidth: '80%',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 12,
  },
  bubbleUser: {
    backgroundColor: '#DCF8C6',
    borderTopRightRadius: 4,
  },
  bubbleBot: {
    backgroundColor: 'white',
    borderTopLeftRadius: 4,
  },
  content: {
    fontSize: 15,
    lineHeight: 20,
  },
  contentUser: {
    color: '#1F2937',
  },
  contentBot: {
    color: '#1F2937',
  },
  meta: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'flex-end',
    gap: 4,
    marginTop: 4,
  },
  time: {
    fontSize: 11,
  },
  timeUser: {
    color: '#6B7280',
  },
  timeBot: {
    color: '#9CA3AF',
  },
});
