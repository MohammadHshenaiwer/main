package com.university.swap.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "student_course_completion")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class StudentCourseCompletion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "completion_id")
    private Long completionId;

    @ManyToOne
    @JoinColumn(name = "student_id", nullable = false)
    private Student student;

    @ManyToOne
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    @Column(name = "status")
    private String status;

    @Column(name = "grade")
    private String grade;

    @Column(name = "term")
    private String term;
}