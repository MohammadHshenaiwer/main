package com.university.swap.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "sections")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Section {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "section_id")
    private Long sectionId;

    @ManyToOne
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    @Column(name = "section_number", nullable = false)
    private String sectionNumber;

    @Column(name = "instructor")
    private String instructor;

    @Column(name = "schedule")
    private String schedule;

    @Column(name = "capacity")
    private Integer capacity;

    @Column(name = "enrolled_count")
    private Integer enrolledCount;
}
