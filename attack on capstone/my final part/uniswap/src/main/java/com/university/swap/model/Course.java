package com.university.swap.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "courses")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Course {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "course_id")
    private Long courseId;

    // Column names match the friend's Supabase 'courses' table
    @Column(name = "name", nullable = false)
    private String courseName;

    @Column(name = "code")
    private String courseCode;

    @Column(name = "credit_hours")
    private Integer credits;

    @Column(name = "prerequisite_course_code")
    private String prerequisiteCourseCode;
}
