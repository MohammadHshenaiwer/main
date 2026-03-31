package com.university.swap.repository;

import com.university.swap.model.Section;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface SectionRepository extends JpaRepository<Section, Long> {
    
    @EntityGraph(attributePaths = {"course"})
    List<Section> findAll();

    @EntityGraph(attributePaths = {"course"})
    List<Section> findByCourse_CourseId(Long courseId);
}

