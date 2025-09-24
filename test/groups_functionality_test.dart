import 'package:flutter_test/flutter_test.dart';
import 'package:peer_assessment_app___mobile___flutter/features/courses/domain/models/group.dart';
import 'dart:math';

// Test utility function for group generation (extracted from GroupGenerationDialog)
List<Group> generateRandomGroups({
  required List<String> availableStudentIds,
  required int numberOfGroups,
  int? groupSize,
}) {
  final random = Random();
  final shuffledStudents = List<String>.from(availableStudentIds)..shuffle(random);
  
  final List<Group> groups = [];
  final int actualGroupSize = groupSize ?? 
      (numberOfGroups > 0 ? (availableStudentIds.length / numberOfGroups).ceil() : 2);
  
  for (int i = 0; i < numberOfGroups; i++) {
    final int start = i * actualGroupSize;
    final int end = (start + actualGroupSize < shuffledStudents.length) 
        ? start + actualGroupSize 
        : shuffledStudents.length;
    
    if (start < shuffledStudents.length) {
      final groupStudents = shuffledStudents.sublist(start, end);
      groups.add(Group(
        id: 'test_group_$i',
        name: 'Grupo ${i + 1}',
        studentIds: groupStudents,
        createdAt: DateTime.now(),
      ));
    }
  }
  
  return groups;
}

void main() {
  group('Group Generation Tests', () {
    test('should create correct number of groups for even distribution', () {
      final studentIds = ['s1', 's2', 's3', 's4', 's5', 's6'];
      final groups = generateRandomGroups(
        availableStudentIds: studentIds,
        numberOfGroups: 2,
      );
      
      expect(groups.length, equals(2));
      expect(groups[0].studentIds.length, equals(3));
      expect(groups[1].studentIds.length, equals(3));
      
      final allAssignedStudents = groups.expand((g) => g.studentIds).toList();
      expect(allAssignedStudents.length, equals(6));
      expect(Set.from(allAssignedStudents).length, equals(6)); // No duplicates
    });
    
    test('should handle uneven distribution correctly', () {
      final studentIds = ['s1', 's2', 's3', 's4', 's5'];
      final groups = generateRandomGroups(
        availableStudentIds: studentIds,
        numberOfGroups: 2,
      );
      
      expect(groups.length, equals(2));
      expect(groups[0].studentIds.length, equals(3));
      expect(groups[1].studentIds.length, equals(2));
      
      final allAssignedStudents = groups.expand((g) => g.studentIds).toList();
      expect(allAssignedStudents.length, equals(5));
    });
    
    test('should handle edge case with more groups than students', () {
      final studentIds = ['s1', 's2'];
      final groups = generateRandomGroups(
        availableStudentIds: studentIds,
        numberOfGroups: 3,
      );
      
      expect(groups.length, equals(2)); // Only creates groups for available students
      expect(groups[0].studentIds.length, equals(1));
      expect(groups[1].studentIds.length, equals(1));
    });
    
    test('should handle empty student list', () {
      final studentIds = <String>[];
      final groups = generateRandomGroups(
        availableStudentIds: studentIds,
        numberOfGroups: 2,
      );
      
      expect(groups.length, equals(0));
    });
    
    test('should create groups with specified group size', () {
      final studentIds = ['s1', 's2', 's3', 's4', 's5', 's6', 's7'];
      final groups = generateRandomGroups(
        availableStudentIds: studentIds,
        numberOfGroups: 3,
        groupSize: 2,
      );
      
      expect(groups.length, equals(3));
      // First two groups should have 2 students, last group might have remaining
      expect(groups[0].studentIds.length, equals(2));
      expect(groups[1].studentIds.length, equals(2));
      // Last group gets the remaining students
      expect(groups[2].studentIds.length, greaterThan(0));
    });
  });
  
  group('Group Model Tests', () {
    test('should create group with correct properties', () {
      final group = Group(
        id: 'test_id',
        name: 'Test Group',
        studentIds: ['s1', 's2'],
        createdAt: DateTime(2024, 1, 1),
      );
      
      expect(group.id, equals('test_id'));
      expect(group.name, equals('Test Group'));
      expect(group.studentIds.length, equals(2));
      expect(group.studentIds, contains('s1'));
      expect(group.studentIds, contains('s2'));
      expect(group.createdAt, equals(DateTime(2024, 1, 1)));
    });
    
    test('should serialize and deserialize correctly', () {
      final originalGroup = Group(
        id: 'test_id',
        name: 'Test Group',
        studentIds: ['s1', 's2'],
        createdAt: DateTime(2024, 1, 1),
      );
      
      final json = originalGroup.toJson();
      final deserializedGroup = Group.fromJson(json);
      
      expect(deserializedGroup.id, equals(originalGroup.id));
      expect(deserializedGroup.name, equals(originalGroup.name));
      expect(deserializedGroup.studentIds, equals(originalGroup.studentIds));
      expect(deserializedGroup.createdAt, equals(originalGroup.createdAt));
    });
  });
}