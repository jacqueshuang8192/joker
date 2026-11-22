package com.j.joker.service.common;

import com.j.joker.mapper.TFeedbackMapper;
import com.j.joker.model.TFeedback;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;

/**
 * Created by dzesla on 2017/2/16.
 */
@Service
public class FeedbackService {
    @Autowired
    private TFeedbackMapper feedbackMapper;

    private static final Logger LOGGER = Logger.getLogger(FeedbackService.class);

    public void problemFeedback(Long userId, String content) {
        TFeedback feedback = new TFeedback();
        feedback.setUserId(userId);
        feedback.setContent(content);
        feedback.setDate(new Date());
        feedbackMapper.insert(feedback);
    }
}
