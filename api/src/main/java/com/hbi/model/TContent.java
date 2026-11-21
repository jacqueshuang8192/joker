//package com.hbi.model;
//
//import java.util.Date;
//import javax.persistence.*;
//
//@Table(name = "t_content")
//public class TContent {
//    @Id
//    @Column(name = "content_id")
//    private Long contentId;
//
//    @Column(name = "category_id")
//    private Long categoryId;
//
//    private String title;
//
//    private String summary;
//
//    private String icon;
//
//    private String author;
//
//    @Column(name = "publish_date")
//    private Date publishDate;
//
//    @Column(name = "create_date")
//    private Date createDate;
//
//    private String state;
//
//    private String content;
//
//    /**
//     * @return content_id
//     */
//    public Long getContentId() {
//        return contentId;
//    }
//
//    /**
//     * @param contentId
//     */
//    public void setContentId(Long contentId) {
//        this.contentId = contentId;
//    }
//
//    /**
//     * @return category_id
//     */
//    public Long getCategoryId() {
//        return categoryId;
//    }
//
//    /**
//     * @param categoryId
//     */
//    public void setCategoryId(Long categoryId) {
//        this.categoryId = categoryId;
//    }
//
//    /**
//     * @return title
//     */
//    public String getTitle() {
//        return title;
//    }
//
//    /**
//     * @param title
//     */
//    public void setTitle(String title) {
//        this.title = title;
//    }
//
//    /**
//     * @return summary
//     */
//    public String getSummary() {
//        return summary;
//    }
//
//    /**
//     * @param summary
//     */
//    public void setSummary(String summary) {
//        this.summary = summary;
//    }
//
//    /**
//     * @return icon
//     */
//    public String getIcon() {
//        return icon;
//    }
//
//    /**
//     * @param icon
//     */
//    public void setIcon(String icon) {
//        this.icon = icon;
//    }
//
//    /**
//     * @return author
//     */
//    public String getAuthor() {
//        return author;
//    }
//
//    /**
//     * @param author
//     */
//    public void setAuthor(String author) {
//        this.author = author;
//    }
//
//    /**
//     * @return publish_date
//     */
//    public Date getPublishDate() {
//        return publishDate;
//    }
//
//    /**
//     * @param publishDate
//     */
//    public void setPublishDate(Date publishDate) {
//        this.publishDate = publishDate;
//    }
//
//    /**
//     * @return create_date
//     */
//    public Date getCreateDate() {
//        return createDate;
//    }
//
//    /**
//     * @param createDate
//     */
//    public void setCreateDate(Date createDate) {
//        this.createDate = createDate;
//    }
//
//    /**
//     * @return state
//     */
//    public String getState() {
//        return state;
//    }
//
//    /**
//     * @param state
//     */
//    public void setState(String state) {
//        this.state = state;
//    }
//
//    /**
//     * @return content
//     */
//    public String getContent() {
//        return content;
//    }
//
//    /**
//     * @param content
//     */
//    public void setContent(String content) {
//        this.content = content;
//    }
//}